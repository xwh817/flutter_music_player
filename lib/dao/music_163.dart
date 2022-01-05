import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_music_player/model/Lyric.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/http_util.dart';

class MusicDao {
  static const URL_ROOT =
      'https://cloud-music-api-f494k233x-mgod-monkey.vercel.app';

  static const URL_PLAY_LIST = '$URL_ROOT/top/playlist?cat=';
  static const URL_PLAY_LIST_DETAIL = '$URL_ROOT/playlist/detail?id=';
  static const URL_RECOMMEND_SONGS = '$URL_ROOT//personalized/newsong';
  static const URL_NEW_SONGS = '$URL_ROOT/personalized/newsong';
  static const URL_TOP_SONGS = '$URL_ROOT/playlist/detail?id=';
  static const URL_SONG_DETAIL = '$URL_ROOT/song/detail?ids=';
  static const URL_GET_LYRIC = '$URL_ROOT/lyric?id=';

  static const URL_MV_FIRST = '$URL_ROOT/mv/first';
  static const URL_MV_TOP = '$URL_ROOT/top/mv';
  static const URL_MV_PERSONAL = '$URL_ROOT/personalized/mv';
  static const URL_MV_DETAIL = '$URL_ROOT/mv/detail?mvid=';
  static const URL_MV_AREA = '$URL_ROOT/mv/all?area=';
  static const URL_MV_163 = '$URL_ROOT/mv/exclusive/rcmd'; // 网易出品mv

  static const URL_SEARCH = '$URL_ROOT/search?keywords=';

  static const URL_GET_TOPLIST =
      '$URL_ROOT/toplist/detail'; // 获取排行和摘要，或者/toplist

  static const URL_TOP_ARTISTS = '$URL_ROOT/toplist/artist';
  static const URL_ARTIST_DETAIL = '$URL_ROOT/artists?id=';

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

  static Future<List> getRecommendSongs() async {
    print('$URL_RECOMMEND_SONGS');
    var data = await HttpUtil.getJsonData('$URL_RECOMMEND_SONGS');
    List songList = data['playlist']['tracks'];
    return songList;
  }

  static Future<List> getTopSongs(int listId) async {
    print('$URL_TOP_SONGS$listId');
    var data = await HttpUtil.getJsonData('$URL_TOP_SONGS$listId');
    List songList = data['playlist']['tracks'];
    return songList;
  }

  // 获取歌词
  static Future<Lyric> getLyric(int songId) async {
    File cache = File(await FileUtil.getLyricLocalPath(songId));
    Map data;
    try {
      bool isCached = cache.existsSync();
      if (isCached) {
        // 歌词缓存过
        String strCached = await cache.readAsString();
        //print('get lyric from cache: $strCached');
        if (strCached.isNotEmpty) {
          data = jsonDecode(strCached);
        } else {
          cache.delete();
        }
      }

      if (data == null) {
        String url = '$URL_GET_LYRIC$songId';
        data = await HttpUtil.getJsonData(url, checkCacheTimeout: false);
      }

      if (data.containsKey('nolyric')) {
        // 无歌词
        return Lyric.empty();
      }
      String str = data['lrc']['lyric'];
      return Lyric(str);
    } catch (e) {
      print('$e');
      return null;
    }
  }

  static Future<List> getMVList(String url) async {
    var data = await HttpUtil.getJsonData(url);
    List mvList;
    if (url == URL_MV_PERSONAL) {
      mvList = (data['result'] as List)
          .map((item) => {
                'id': item['id'],
                'name': item['name'],
                'cover': item['picUrl'],
                'artistNames': item['artistName'],
              })
          .toList();
    } else {
      mvList = data['data'];
    }
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
    var data =
        await HttpUtil.getJsonData('$URL_SEARCH$keywords', useCache: false);
    List songList = data['result']['songs'];
    return songList;
  }

  static Future<List> getSongDetails(String ids) async {
    var data =
        await HttpUtil.getJsonData('$URL_SONG_DETAIL$ids', useCache: false);
    List songList = data['songs'];
    return songList;
  }

  static Future<Map> getSongDetail(String id) async {
    List songList = await getSongDetails(id);
    Map song;
    if (songList.length > 0) {
      song = songList[0];
    }
    return song;
  }

  static Future<List> getArtistList() async {
    var data = await HttpUtil.getJsonData(URL_TOP_ARTISTS);
    List songList = data['list']['artists'];
    return songList;
  }

  static Future<Map> getArtistDetail(int id) async {
    Map detail = await HttpUtil.getJsonData('$URL_ARTIST_DETAIL$id');
    Map artist = detail['artist'];
    Map content = {
      'id': artist['id'],
      'name': artist['name'],
      'desc': artist['briefDesc'],
      'image': artist['picUrl'],
      'songs': detail['hotSongs'],
    };
    return content;
  }
}
