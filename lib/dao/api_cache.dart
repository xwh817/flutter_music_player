import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/network_util.dart';

class APICache {
  static const String dirName = 'cache';
  static const Duration CACHE_TIMEOUT = Duration(hours: 6);  // 缓存超时时长。

  static Future<File> _getLocalFile(String url) async {
    String fileName = md5.convert(utf8.encode(url)).toString();
    String dir = await FileUtil.getSubDirPath(dirName);
    return new File('$dir/$fileName');
  }

  static Future<String> getCache(String url, {checkTime:true}) async{
    String cache;
    File file = await _getLocalFile(url);
    if (await file.exists()) {
      // 判断网络和缓存时间
      if (checkTime && NetworkUtil().isNetworkAvailable()
          && await FileUtil.isFileTimeout(file, CACHE_TIMEOUT)) {  // 缓存超时了，并且网络可用，丢掉之前的。
        file.delete();
        print('缓存超时：$url');
      } else {
        cache = await file.readAsString();
        print('从缓存获取：$url');
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


  static Future<FileSystemEntity> deleteCache(String url) async{
    File file = await _getLocalFile(url);
    print('deleteCache: ${file.path}');
    return file.delete();
  }

  static void clearCache() async{
    //Directory dir = await _getCacheDir();
    //dir.delete(recursive:true);
  }
}
