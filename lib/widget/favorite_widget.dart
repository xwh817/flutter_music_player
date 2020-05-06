import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/api_cache.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/dao/music_db_favorite.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/http_util.dart';
import 'package:flutter_music_player/utils/shared_preference_util.dart';
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
        color: isFavorited
            ? Provider.of<ColorStyleProvider>(context, listen: false)
                .getCurrentColor()
            : Colors.white60,
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

  _showSnackBar({IconData icon, String title, String subTitle}) {
    SnackBar snackBar = SnackBar(
        content: ListTile(
          leading: Icon(icon),
          title: Text(title, style: TextStyle(fontSize: 14.0)),
          subtitle:
              Text(subTitle, style: TextStyle(fontSize: 13.0, height: 2.0)),
        ),
        duration: Duration(seconds: 3));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _addFavorite(context) {
    bool success = false;
    bool downloadOnFav =
        SharedPreferenceUtil.getInstance().getBool('downloadOnFav') ?? false;

    FavoriteDB().addFavorite(widget.song).then((re) {
      print('addFavorite re: $re , song: ${widget.song}');
    }).then((_) {
      if (downloadOnFav) {
        _downloadMp3();
        _downloadLyric();
      }

      setState(() {
        isFavorited = true;
      });
      success = true;
    }).catchError((error) {
      print('addFavorite error: $error');
      success = false;
    }).whenComplete(() {
      _showSnackBar(
          icon: downloadOnFav ? Icons.file_download : Icons.favorite,
          title: success ? '已添加收藏' : '添加收藏失败',
          subTitle: success && downloadOnFav ? '正在下载歌曲...' : '');
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

  Future<void> _downloadMp3() async {
    String savePath = await FileUtil.getSongLocalPath(widget.song['id']);
    String url = SongUtil.getSongUrl(widget.song);
    HttpUtil.download(url, savePath);
    print('download: $url');
  }

  Future<void> _downloadLyric() async {
    int songId = widget.song['id'];
    String path = await FileUtil.getLyricLocalPath(songId);
    String url = '${MusicDao.URL_GET_LYRIC}$songId';
    File cache = await APICache.getLocalFile(url);
    if (cache.existsSync()) {
      print('歌词已经缓存过');
      cache.copySync(path);
    } else {
      print('下载歌词');
      HttpUtil.download(url, path);
    }
  }
}
