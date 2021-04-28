import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:provider/provider.dart';

class SongItemText extends StatefulWidget {
  final List songList;
  final int index;
  final Function onItemTap;
  const SongItemText(this.songList, this.index, {Key key, this.onItemTap})
      : super(key: key);

  @override
  _SongItemTextState createState() => _SongItemTextState();
}

class _SongItemTextState extends State<SongItemText> {
  bool selected = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MusicController musicController =
        Provider.of<MusicController>(context, listen: false);
    Map song = widget.songList[widget.index];
    Color itemColor = Colors.black54;
    if (widget.index == musicController.getCurrentIndex()) {
      itemColor = Provider.of<ColorStyleProvider>(context, listen: false)
          .getCurrentColor();
    }
    return InkWell(
        onTap: () {
          musicController.playIndex(widget.index);
          widget.onItemTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: song['name'],
                  style: TextStyle(fontSize: 15.0, color: itemColor),
                ),
                TextSpan(
                    text: ' - ' + SongUtil.getArtistNames(song),
                    style: TextStyle(fontSize: 13.0, color: itemColor))
              ])),
          /* child: Row(
            children: <Widget>[
              Text(
                "${song['name']}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0, color: itemColor),
              ),
              Text(
                " - ${SongUtil.getArtistNames(song)}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.0, color: itemColor),
              )
            ],
          ), */
        ));
  }
}
