import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

class RankSongList extends StatefulWidget {
  final int topId;
  final String topName;
  RankSongList(this.topId, this.topName, {Key key}) : super(key: key);

  @override
  _RankSongListState createState() => _RankSongListState();
}

class _RankSongListState extends State<RankSongList> {
  List _songs = List();

  _getSongs() async {
    await MusicDao.getTopSongs(widget.topId).then((result) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(widget.topName, style: TextStyle(fontSize: 16.0)),
      ),
      body: _songs.length == 0
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length,
              itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
              itemBuilder: (context, index) => SongItemTile(_songs, index),
            ),
    );
  }
}
