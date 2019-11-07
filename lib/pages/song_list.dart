import 'package:flutter/material.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import '../dao/music_163.dart';

class SongList extends StatefulWidget {
  SongList({Key key}) : super(key: key);

  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List _songs = List();

  _getSongs() async {
    await MusicDao.getTopSongs(0).then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _songs = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  Widget mWidget;

  @override
  Widget build(BuildContext context) {
    if (_songs.length == 0) {
      // 显示进度条
      mWidget = Center(child: CircularProgressIndicator());
    } else {
      mWidget = ListView.builder(
        itemCount: this._songs.length,
        itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
        itemBuilder: (context, index) => SongItemTile(_songs, index),
      );
    }
    return mWidget;
  }

}
