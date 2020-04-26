import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db_playlist.dart';

class FavoritePlayListIcon extends StatefulWidget {
  final Map play;
  const FavoritePlayListIcon(this.play, {Key key}) : super(key: key);

  @override
  _FavoritePlayListIconState createState() => _FavoritePlayListIconState();
}

class _FavoritePlayListIconState extends State<FavoritePlayListIcon> {
  bool isFavorited = false;
  Map play;

  @override
  void initState() {
    super.initState();
    //print('FavoritePlayListIcon initState');
  }

  void _checkFavorite() {
    PlayListDB().getPlayListById(play['id']).then((fav) {
      //print('getFavoriteById : $fav');
      setState(() {
        isFavorited = fav != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.play != play) {
      play = widget.play;
      _checkFavorite();
    }
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color: isFavorited
            ? Colors.white
            : Colors.white30,
      ),
      onPressed: () {
        if (this.isFavorited) {
          _cancelFavorite(context);
        } else {
          _addFavorite(context);
        }
      },
    );
  }

  void _addFavorite(context) {
    PlayListDB().addPlayList(widget.play).then((re) {
      print('addFavorite re: $re , play: ${widget.play}');
      setState(() {
        isFavorited = true;
      });
    }).catchError((error) {
      print('addFavorite error: $error');
    });
  }

  void _cancelFavorite(context) {
    PlayListDB().deletePlayList(widget.play['id']).then((re) {
      setState(() {
        isFavorited = false;
      });
    }).catchError((error) {
      print('deleteFavorite error: $error');
      throw Exception('取消收藏失败');
    });
  }

}
