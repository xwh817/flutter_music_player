import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class APICache {
  static const String dirName = 'cache';
  static const Duration CACHE_TIMEOUT = Duration(hours: 6);  // 缓存超时时长。


  static Future<Directory> _getCacheDir() async {
    // get the path to the document directory.
    String root = (await getApplicationDocumentsDirectory()).path;
    String dirPath = '$root/$dirName';
    Directory dir = new Directory(dirPath);
    if (!await dir.exists()) {  // 如果目录不存在，就创建
      dir.create();
    }
    return dir;
  }
  static Future<File> _getLocalFile(String url) async {
    String fileName = md5.convert(utf8.encode(url)).toString();
    Directory dir = await _getCacheDir();
    return new File('${dir.path}/$fileName');
  }

  static Future<String> getCache(String url) async{
    String cache;
    File file = await _getLocalFile(url);
    if (await file.exists()) {
      DateTime lastModified = await file.lastModified();
      DateTime now = DateTime.now();
      
      // 比较时间
      if (now.isAfter(lastModified.add(CACHE_TIMEOUT))) {  // 缓存超时了，丢掉。
        file.delete();
        print('缓存超时：$url');
      } else {
        cache = await file.readAsString();
        print('缓存未超时，获取成功：$url');
      }
      
    }
    return cache;
  }

  static Future<bool> saveCache(String url, String cache) async{
    File file = await _getLocalFile(url);
    print('saveCache to: ${file.path}');
    File fileCached = await file.writeAsString(cache);
    return fileCached.exists();
  }

  static void clearCache() async{
    Directory dir = await _getCacheDir();
    dir.delete(recursive:true);
  }
}
