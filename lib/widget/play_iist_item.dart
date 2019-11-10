import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/play_list_detail.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';


class PlayListItem extends StatelessWidget {
  final Map play;
  const PlayListItem(this.play, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            child: Hero(
              tag: "playListImage_${play['id']}", // 一个页面中tag名需唯一，所以list中要加上id
              child: CachedNetworkImage(imageUrl: '${play['coverImgUrl']}?param=300y300'),
            )
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
                  play['name'],
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
                    NavigatorUtil.push(context, PlayListPage(playlist: play));
                  }),
            ),
          ),
        ],
      );
  }
}