import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_music_player/dao/api_cache.dart';
import 'package:flutter_music_player/model/Lyric.dart';

class MusicDao {
  static const URL_ROOT = 'http://music.turingmao.com';
  static const URL_PLAY_LIST = '$URL_ROOT/top/playlist?cat=';
  static const URL_PLAY_LIST_DETAIL = '$URL_ROOT/playlist/detail?id=';
  static const URL_NEW_SONGS = '$URL_ROOT/personalized/newsong';
  static const URL_TOP_SONGS = '$URL_ROOT/top/list?idx=';
  static const URL_GET_LYRIC = '$URL_ROOT/lyric?id=';
  static const URL_MV_LIST = '$URL_ROOT/mv/first';
  static const URL_MV_DETAIL = '$URL_ROOT/mv/detail?mvid=';


  static Future getJsonData(String url, {bool useCache: true}) async {
    var data;
    if (useCache) { // 有些资源是动态的,如播放地址，会过期不能使用缓存。
      String cache = await APICache.getCache(url);
      if (cache != null) {
        data = jsonDecode(cache);
      }
    }
    // 缓存没取到，就请求网络。
    if (data == null) {
      var httpClient = new HttpClient();
      print("http request: $url");
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        bool re = await APICache.saveCache(url, json);
        print('saveCache result: $re');
        data = jsonDecode(json);
      } else {
        throw Exception(
            'Request failed, errorCode: ${response.statusCode}');
      }
    }
    
    return data;
  }


  static Future<List> getPlayList(String cat) async {
    var data = await getJsonData(URL_PLAY_LIST + cat);
    List playlist = data['playlists'];
    return playlist;
  }

  
  static Future<List> getPlayListDetail(int listId) async {
    var data = await getJsonData('$URL_PLAY_LIST_DETAIL$listId');
    List playlist = data['playlist']['tracks'];
    return playlist;
  }
  
  static Future<List> getNewSongs() async {
    var data = await getJsonData(URL_NEW_SONGS);
    List songList = data['result'];
    return songList;
  }

  static Future<List> getTopSongs(int listId) async {
    var data = await getJsonData('$URL_TOP_SONGS$listId');
    List songList = data['playlist']['tracks'];
    return songList;
  }

  // 获取歌词
  static Future<Lyric> getLyric(int songId) async {
    var data = await getJsonData('$URL_GET_LYRIC$songId');
    String str = data['lrc']['lyric'];
    return Lyric(str);
  }

  static Future<List> getMVList() async {
    var data = await getJsonData(URL_MV_LIST);
    List mvList = data['data'];
    return mvList;
  }

  
  static Future<String> getMVDetail(int id) async {
    var data = await getJsonData('$URL_MV_DETAIL$id', useCache: false);
    // 视频 240 480 720 1080
    String url = data['data']['brs']['480'];
    return url;
  }

}
