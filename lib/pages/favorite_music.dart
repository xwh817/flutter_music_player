import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db_favorite.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

class FavoriteMusic extends StatefulWidget {
  FavoriteMusic({Key key}) : super(key: key);

  _FavoriteMusicState createState() => _FavoriteMusicState();
}

class _FavoriteMusicState extends State<FavoriteMusic> {
  List _songs;

  _getSongs() async {
    FavoriteDB().getFavoriteList().then((result) {
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
    if (_songs == null) {
      return Container();
    }
    if (_songs.length == 0) {
      return Center(
          child: Text(
        '您还没有收藏歌曲\n可点击播放页右上角进行收藏。',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, height: 1.5),
      ));
    } else {
      return ListView.builder(
        itemCount: this._songs.length,
        itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
        itemBuilder: (context, index) => SongItemTile(_songs, index),
      );
    }
  }

}
