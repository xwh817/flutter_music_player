import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/mv_player_page.dart';
import 'package:flutter_music_player/test/video_demo.dart';
import 'package:flutter_music_player/widget/my_video_player.dart';
import 'package:video_player/video_player.dart';
import 'music_progress_bar_2.dart';

class MVItem extends StatefulWidget {
  final Map mv;
  MVItem(this.mv, {Key key}) : super(key: key);

  @override
  _MVItemState createState() => _MVItemState();
}


class _MVItemState extends State<MVItem> {

  @override
  void dispose() {
    super.dispose();
    print('MVItem dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('MVItem deactivate');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              // 设定宽高比
              aspectRatio: 16 / 9,
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(10.0),
                child: MyVideoPlayer(
                  mv: widget.mv,
                ),
              ),
            ),
            Text(
              widget.mv['name'],
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  height: 1.6),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              SongUtil.getArtistNames(widget.mv),
              style:
                  TextStyle(fontSize: 14.0, color: Colors.black54, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ));
  }

}
