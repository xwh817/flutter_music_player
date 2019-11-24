import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/widget/song_item_text.dart';
import 'package:provider/provider.dart';

class CurrentPlayList extends StatefulWidget {
  CurrentPlayList({Key key}) : super(key: key);

  @override
  _CurrentPlayListState createState() => _CurrentPlayListState();
}

class _CurrentPlayListState extends State<CurrentPlayList> {
  final itemHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    MusicController musicController =
        Provider.of<MusicController>(context, listen: false);
    List songs = musicController.playList.songList;
    double initScroll = itemHeight * (musicController.getCurrentIndex() - 3);
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0)),
        child: Container(
          color: Colors.white.withOpacity(0.9),
          padding: EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            controller: ScrollController(initialScrollOffset: initScroll),
            itemCount: songs.length,
            itemExtent: itemHeight, // 设定item的高度，这样可以减少高度计算。
            itemBuilder: (context, index) => SongItemText(
              songs,
              index,
              onItemTap: () {
                Future.delayed(Duration(milliseconds: 300)).then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
        ));
  }
}
