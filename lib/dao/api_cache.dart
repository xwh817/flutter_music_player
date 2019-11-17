import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APICache {
  static const String dirName = 'cache';
  static const Duration CACHE_TIMEOUT_API = Duration(hours: 6); // api缓存超时时长。
  static const Duration CACHE_TIMEOUT_FILE = Duration(days: 7); // 文件缓存超时时长。

  static Future<File> getLocalFile(String url) async {
    String fileName = md5.convert(utf8.encode(url)).toString();
    String dir = (await FileUtil.createLocalDir(dirName)).path;
    return new File('$dir/$fileName');
  }

  static Future<String> getCache(String url, {checkCacheTimeout: true}) async {
    String cache;
    File file = await getLocalFile(url);
    if (await file.exists()) {
      // 判断网络和缓存时间
      if (checkCacheTimeout &&
          NetworkUtil().isNetworkAvailable() &&
          FileUtil.isFileTimeout(file, CACHE_TIMEOUT_API)) {
        // 缓存超时了，并且网络可用，丢掉之前的。
        //file.delete(); // 网络请求成功才删除。
        print('缓存超时：$url');
      } else {
        cache = await file.readAsString();
        print('从缓存获取：$url');
      }
    }
    return cache;
  }

  static Future<bool> saveCache(String url, String cache) async {
    File file = await getLocalFile(url);
    print('saveCache to: ${file.path}');
    File fileCached;
    try {
      fileCached = await file.writeAsString(cache);
    } catch (e) {
      print(e);
    }
    return fileCached?.exists();
  }

  static Future<FileSystemEntity> deleteCache(String url) async {
    File file = await getLocalFile(url);
    print('deleteCache: ${file.path}');
    return file.delete();
  }

  /// 清理一段时间之前的缓存
  /// 例如歌词文件
  static Future<int> clearCache() async {
    int count = 0;
    // 两天才检查一次，不用每次启动都遍历一次文件夹。
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastTime = prefs.getInt('lastClearCacheTime') ?? 0;
    DateTime lastClearTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
    if (FileUtil.isTimeOut(lastClearTime, CACHE_TIMEOUT_FILE)) {
      String path = await FileUtil.getSubDirPath(dirName);
      Directory dir = Directory(path);
      if (await dir.exists()) {
        List<FileSystemEntity> list = dir.listSync();
        if (list.length > 100) {  // 文件太多才清理。
          list.forEach((item) {
            File file = File(item.path);
            if (FileUtil.isFileTimeout(file, CACHE_TIMEOUT_FILE)) {
              file.delete();
              print('缓存文件过期，cache: ${file.path}');
              count++;
            }
          });
        }
      }
      prefs.setInt('lastClearCacheTime', DateTime.now().millisecondsSinceEpoch);

      if (count == 0) {
        print('没有缓存过期');
      }
    } else {
      print('Last time of clear cache is : ${lastClearTime.toString()}');
    }

    return count;
  }
}
