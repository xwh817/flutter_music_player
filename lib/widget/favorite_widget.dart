import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/file_util.dart';
import 'package:flutter_music_player/utils/http_util.dart';

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
    MusicDB().getFavoriteById(song['id']).then((fav) {
      print('getFavoriteById : $fav');
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
          color: isFavorited ? Colors.pink : Colors.white60,
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


  void _favorite(context){
    bool success = false;
    MusicDB().addFavorite(widget.song).then((re){
        print('addFavorite re: $re , song: ${widget.song}');
      }).then((_){
        return FileUtil.getSongLocalPath(widget.song);
      }).then((savePath){
        String url = SongUtil.getSongUrl(widget.song);
        HttpUtil.download(url, savePath);
        print('download: $url');
        setState(() {
          isFavorited = true;
        });
        success = true;
      }).catchError((error){
        print('addFavorite error: $error');
        success = false;
      }).whenComplete((){
        
        SnackBar snackBar = SnackBar(content: ListTile(
          title: Text(success ? '已添加收藏' : '添加收藏失败'),
          subtitle: Text(success ? '正在下载歌曲...' : ''),
        ), duration: Duration(seconds: 2));
        Scaffold.of(context).showSnackBar(snackBar);
      });
  }

  void _cancelFavorite(context){
    bool success = false;
    showDialog(context: context, barrierDismissible: true, 
    builder: (_)=>AlertDialog(
      title: Text('取消收藏？'),
      content: Text(('已下载歌曲会被删掉')),
      actions: <Widget>[
        new FlatButton(
          child: new Text("继续收藏"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text("确定删除"),
          onPressed: () {    
            MusicDB().deleteFavorite(widget.song['id'])
            .then((re){
              return FileUtil.deleteLocalSong(widget.song);
            }).then((re){
              success = true;
              Navigator.of(context).pop();
              setState(() {
                isFavorited = false;
              });
            }).catchError((error){
              success = false;
              print('deleteFavorite error: $error');
              throw Exception('取消收藏失败');
            }).whenComplete((){
              SnackBar snackBar = SnackBar(content: ListTile(
                title: Text(success ? '已取消收藏' : '取消收藏失败'),
                subtitle: Text(success ? '正在取消...' : ''),
              ), duration: Duration(seconds: 1));
              Scaffold.of(context).showSnackBar(snackBar);
          });
          },
        ),
      ],
    ));

  }


}