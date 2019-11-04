import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/widget/my_video_player.dart';
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
    print('MVItem dispose ${widget.mv['name']}');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('MVItem deactivate ${widget.mv['name']}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: AspectRatio(
                // 设定宽高比
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  // 圆角
                  borderRadius: BorderRadius.circular(8.0),
                  child: MyVideoPlayer(
                    mv: widget.mv,
                  ),
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 4.0),
              child: Text(
                widget.mv['name'],
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 8.0),
              child: Text(
                SongUtil.getArtistNames(widget.mv),
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ),
            Divider(height: 20.0, thickness: 8.0, color: Colors.grey[200],)

          ],
        );
  }

}
