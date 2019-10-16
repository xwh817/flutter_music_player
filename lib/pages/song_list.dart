import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import './player_page.dart';

class SongList extends StatefulWidget {
  SongList({Key key}) : super(key: key);

  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List _songs = List();

  _getSongs() async {
    var url = 'http://music.turingmao.com/top/list?idx=0';
    var httpClient = new HttpClient();
    List songs;
    try {
      print("http request: $url");
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        songs = data['playlist']['tracks'];
      } else {
        print('Error: Http status ${response.statusCode}');
      }

      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _songs = songs;
      });
    } catch (exception) {
      print('Failed: ${exception.message}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  Widget mWidget;

  @override
  Widget build(BuildContext context) {
    if (_songs.length == 0) { // 显示进度条
      mWidget = Center(child: CircularProgressIndicator());
    } else {
      mWidget = ListView.builder(
        itemCount: this._songs.length,
        itemBuilder: (context, index) => _bulidItem(context, index),
      );
    }
    return mWidget;
  }

  _bulidItem(BuildContext context, int index) {
    Map song = _songs[index];

    return new ListTile(
      title: new Text("$index ${song['name']}"),
      subtitle: new Text(song['ar'][0]['name']),
      leading: new ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: new Image.network("${song['al']['picUrl']}?param=100y100"),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlayerPage(song: song)));
      },
    );
  }
}
