import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db_favorite.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/http_util.dart';
import 'package:provider/provider.dart';

class FavoriteIcon extends StatefulWidget {
  final Map song;
  const FavoriteIcon(this.song, {Key key}) : super(key: key);

  @override
  _FavoriteIconState createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  bool isFavorited = false;
  Map song;

  @override
  void initState() {
    super.initState();
    //print('FavoriteIcon initState');
  }

  void _checkFavorite() {
    FavoriteDB().getFavoriteById(song['id']).then((fav) {
      //print('getFavoriteById : $fav');
      setState(() {
        isFavorited = fav != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.song != song) {
      song = widget.song;
      _checkFavorite();
    }
    //print('FavoriteIcon build');
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color: isFavorited ? Provider.of<ColorStyleProvider>(context, listen: false).getCurrentColor() : Colors.white60,
      ),
      onPressed: () {
        if (this.isFavorited) {
          _cancelFavorite(context);
        } else {
          _favorite(context);
        }
      },
    );
  }

  _showSnackBar({IconData icon, String title, String subTitle}) {
    SnackBar snackBar = SnackBar(
        content: ListTile(
          leading: Icon(icon),
          title: Text(title, style: TextStyle(fontSize: 16.0)),
          subtitle:
              Text(subTitle, style: TextStyle(fontSize: 14.0, height: 2.0)),
        ),
        duration: Duration(seconds: 3));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _favorite(context) {
    bool success = false;
    FavoriteDB().addFavorite(widget.song).then((re) {
      print('addFavorite re: $re , song: ${widget.song}');
    }).then((_) {
      return FileUtil.getSongLocalPath(widget.song);
    }).then((savePath) {
      String url = SongUtil.getSongUrl(widget.song);
      HttpUtil.download(url, savePath);
      print('download: $url');
      setState(() {
        isFavorited = true;
      });
      success = true;
    }).catchError((error) {
      print('addFavorite error: $error');
      success = false;
    }).whenComplete(() {
      _showSnackBar(
          icon: Icons.file_download,
          title: success ? '已添加收藏' : '添加收藏失败',
          subTitle: success ? '正在下载歌曲...' : '');
    });
  }

  void _cancelFavorite(context) {
    bool success = false;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              title: Text('取消收藏？', style: TextStyle(fontSize: 16.0)),
              content: Text('已下载歌曲会被删掉', style: TextStyle(fontSize: 14.0)),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("继续收藏"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("删除", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    FavoriteDB().deleteFavorite(widget.song['id']).then((re) {
                      return FileUtil.deleteLocalSong(widget.song);
                    }).then((re) {
                      success = true;
                      Navigator.of(context).pop();
                      setState(() {
                        isFavorited = false;
                      });
                    }).catchError((error) {
                      success = false;
                      print('deleteFavorite error: $error');
                      throw Exception('取消收藏失败');
                    }).whenComplete(() {
                      _showSnackBar(
                          icon: Icons.delete_sweep,
                          title: success ? '已取消收藏' : '取消收藏失败',
                          subTitle: success ? '正在取消...' : '');
                    });
                  },
                ),
              ],
            ));
  }
}
