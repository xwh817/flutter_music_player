import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';
import 'package:provider/provider.dart';

class SongItemTile extends StatelessWidget {
  final List songList;
  final int index;
  final Function onItemTap;
  const SongItemTile(this.songList, this.index, {Key key, this.onItemTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map song = this.songList[index];
    String image = SongUtil.getSongImage(song);
    return new ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: image.isEmpty
            ? Image.asset('images/music_2.jpg', fit: BoxFit.cover)
            : CachedNetworkImage(imageUrl: image),
      ),
      title: new Text(
        "${song['name']}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14.0),
      ),
      subtitle: new Text(
        SongUtil.getArtistNames(song),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.0),
      ),
      onTap: () {
        if (onItemTap != null) {
          this.onItemTap();
        }
        PlayerPage.gotoPlayer(context, list:songList, index:index);
      },
    );
  }
}
