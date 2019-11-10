import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';

class SongItemOfGrid extends StatelessWidget {
  final List songList;
  final int index;
  const SongItemOfGrid(this.songList, this.index, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map song = this.songList[index];
    String image = SongUtil.getSongImage(song, size: 200);
    return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            child: image.isEmpty
                ? Image.asset('images/music_2.jpg', fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        Image.asset('images/music_2.jpg', fit: BoxFit.cover)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0)),
            child: Container(
                width: double.infinity,
                color: Color.fromARGB(80, 0, 0, 0),
                padding: EdgeInsets.all(6.0),
                child: Text(
                  song['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                )),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  // 水波纹
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: () {
                    PlayerPage.gotoPlayer(context,
                        list: songList, index: index);
                  }),
            ),
          ),
        ]);
  }
}
