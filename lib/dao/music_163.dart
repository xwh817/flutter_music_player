import 'dart:async';
import 'package:flutter_music_player/model/Lyric.dart';
import 'package:flutter_music_player/utils/http_util.dart';


class MusicDao {
  static const URL_ROOT = 'http://music.turingmao.com';
  static const URL_PLAY_LIST = '$URL_ROOT/top/playlist?cat=';
  static const URL_PLAY_LIST_DETAIL = '$URL_ROOT/playlist/detail?id=';
  static const URL_NEW_SONGS = '$URL_ROOT/personalized/newsong';
  static const URL_TOP_SONGS = '$URL_ROOT/top/list?idx=';
  static const URL_SONG_DETAIL = '$URL_ROOT/song/detail?ids=';
  static const URL_GET_LYRIC = '$URL_ROOT/lyric?id=';
  static const URL_MV_LIST = '$URL_ROOT/mv/first';
  static const URL_MV_DETAIL = '$URL_ROOT/mv/detail?mvid=';
  static const URL_SEARCH = '$URL_ROOT/search?keywords=';


  static Future<List> getPlayList(String cat) async {
    var data = await HttpUtil.getJsonData(URL_PLAY_LIST + cat);
    List playlist = data['playlists'];
    return playlist;
  }

  
  static Future<List> getPlayListDetail(int listId) async {
    var data = await HttpUtil.getJsonData('$URL_PLAY_LIST_DETAIL$listId');
    List playlist = data['playlist']['tracks'];
    return playlist;
  }
  
  static Future<List> getNewSongs() async {
    var data = await HttpUtil.getJsonData(URL_NEW_SONGS);
    List songList = data['result'];
    return songList;
  }

  static Future<List> getTopSongs(int listId) async {
    var data = await HttpUtil.getJsonData('$URL_TOP_SONGS$listId');
    List songList = data['playlist']['tracks'];
    return songList;
  }

  // 获取歌词
  static Future<Lyric> getLyric(int songId) async {
    Map data = await HttpUtil.getJsonData('$URL_GET_LYRIC$songId', checkCacheTimeout: false);
    if (data.containsKey('nolyric')) {  // 无歌词
      return Lyric.empty();
    }
    String str = data['lrc']['lyric'];
    return Lyric(str);
  }

  static Future<List> getMVList() async {
    var data = await HttpUtil.getJsonData(URL_MV_LIST);
    List mvList = data['data'];
    return mvList;
  }

  
  static Future<String> getMVDetail(int id) async {
    var data = await HttpUtil.getJsonData('$URL_MV_DETAIL$id', useCache: false);
    // 视频 240 480 720 1080
    String url = data['data']['brs']['480'];
    print('getMVDetail result: $url');
    return url;
  }

  
  static Future<List> search(String keywords) async {
    var data = await HttpUtil.getJsonData('$URL_SEARCH$keywords', useCache: false);
    List songList = data['result']['songs'];
    return songList;
  }

  static Future<List> getSongDetail(String ids) async {
    var data = await HttpUtil.getJsonData('$URL_SONG_DETAIL$ids', useCache: false);
    List songList = data['result']['songs'];
    return songList;
  }

}
