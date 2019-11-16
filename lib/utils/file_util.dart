import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
/// 本地文件工具类
class FileUtil{
  static final String songsDir = "songs";
  static final String lyricDir = "lyrics";
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
  static Future<String> getSongLocalPath(int songId) async {
    String dir = await getSubDirPath(songsDir);
    String fileName = '$songId.mp3';
    String filePath = '$dir/$fileName';
    return filePath;
  }

    /// 获取收藏歌曲歌词
  static Future<String> getLyricLocalPath(int songId) async {
    String dir = await getSubDirPath(lyricDir);
    String fileName = '$songId.lyric';
    String filePath = '$dir/$fileName';
    return filePath;
  }


  /// 删除文件
  static Future<bool> deleteLocalSong(Map song) async {
    int songId = song['id'];
    deleteFile(await getSongLocalPath(songId));
    deleteFile(await getLyricLocalPath(songId));
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
  static bool isFileTimeout(File file, Duration duration) {
    DateTime lastModified = file.lastModifiedSync();
    return isTimeOut(lastModified, duration);
  }

  /// 判断上一次事件是否超过
  static bool isTimeOut(DateTime lastTime, Duration duration) {
    DateTime now = DateTime.now();
    return now.isAfter(lastTime.add(duration));
  }

}