import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';

class SongItemTile extends StatelessWidget {
  final Map song;
  final Function onItemTap;
  const SongItemTile(this.song, {Key key, this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String image = SongUtil.getSongImage(song);
    return new ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: image.isEmpty
          ? Image.asset('images/music_2.jpg',fit: BoxFit.cover)
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
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlayerPage()));
      },
    );
  }

}
