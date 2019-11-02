import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage({Key key}) : super(key: key);

  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List _songs = List();

  _getSongs() async {
    MusicDB().getFavoriteList().then((result) {
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
      mWidget = Center(
          child: Text(
            '您还没有收藏歌曲\n可点击播放页右上角进行收藏。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
      ));
    } else {
      mWidget = ListView.builder(
        itemCount: this._songs.length,
        itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
        itemBuilder: (context, index) => _buildItem(index),
      );
    }
    return mWidget;
  }

  Widget _buildItem(index) {
    Map fav = this._songs[index];
    Map song = {
      'id': fav['id'],
      'name': fav['name'],
      'artistNames': fav['artist'],
      'imageUrl': fav['cover']
    };
    return SongItemTile(song);
  }
}
