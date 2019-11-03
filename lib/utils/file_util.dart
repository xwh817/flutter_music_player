import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

/// 本地文件工具类
class FileUtil{
  static final String songsDir = "songs";
  static final String music = ".mp3";


  /// 获取子目录路径
  static Future<String> getSubDirPath(String subDirPath) async {
    // get the path to the document directory.
    String root = (await getApplicationDocumentsDirectory()).path;
    return '$root/$subDirPath';
  }


  /// 相对app目录之下创建子目录
  static Future<Directory> createLocalDir(String subDirPath) async {
    String dirPath = await getSubDirPath(subDirPath);
    Directory dir = new Directory(dirPath);
    if (await dir.exists()) {  // 如果目录不存在，就创建
      return dir;
    } else {
      return dir.create(recursive: true);
    }
    
  }

  /// 判断文件是否存在
  static Future<bool> isFileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// 获取歌曲本地路径
  static Future<String> getSongLocalPath(Map song) async {
    String dir = await getSubDirPath(songsDir);
    String fileName = '${song['id']}.mp3';
    String filePath = '$dir/$fileName';
    return filePath;
  }
  /// 删除文件
  static Future<bool> deleteLocalSong(Map song) async {
    String path = await getSongLocalPath(song);
    File file = File(path);
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
    return true;
  }

  /// 删除文件
  static Future<bool> deleteFile(String path) async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
    return true;
  }


  /// 判断文件是否超时
  static Future<bool> isFileTimeout(File file, Duration time) async {
    DateTime lastModified = await file.lastModified();
    DateTime now = DateTime.now();
    return now.isAfter(lastModified.add(time));
  }

}