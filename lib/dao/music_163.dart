import 'dart:async';
import 'dart:io';
import 'dart:convert';

class MusicDao {
  static const URL_ROOT = 'http://music.turingmao.com';
  static const URL_PLAY_LIST = '$URL_ROOT/top/playlist?cat=';
  static const URL_PLAY_LIST_DETAIL = '$URL_ROOT/playlist/detail?id=';
  static const URL_NEW_SONGS = '$URL_ROOT/personalized/newsong';
  static const URL_TOP_SONGS = '$URL_ROOT/top/list?idx=';

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

  static Future getJsonData(String url) async {
    var data;
    var httpClient = new HttpClient();
    print("http request: $url");
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var json = await response.transform(utf8.decoder).join();
      data = jsonDecode(json);
    } else {
      throw Exception(
          'Request failed, errorCode: ${response.statusCode}');
    }
    return data;
  }

}
