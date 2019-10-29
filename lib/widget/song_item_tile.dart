import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';

class SongItemTile extends StatelessWidget {
  final Map song;
  const SongItemTile(this.song, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        "${song['name']}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14.0),
      ),
      subtitle: new Text(SongUtil.getArtistNames(song),
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.0),
      ),
      leading: new ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: CachedNetworkImage(imageUrl: "${song['al']['picUrl']}?param=100y100"),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlayerPage(song: song)));
      },
    );
  }
}