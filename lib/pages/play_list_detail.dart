import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

/// 歌单页
/// 笔记：在state里面获取widget中定义的变量使用widget.playlist
///
class PlayListPage extends StatefulWidget {
  final Map playlist;
  PlayListPage({Key key, @required this.playlist}) : super(key: key);

  _PlayListPageState createState() => _PlayListPageState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class _PlayListPageState extends State<PlayListPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  double _appBarHeight = 256.0;
  List _songs = List();
  bool _imageLoaded = true;

  @override
  void initState() {
    // appBar和图片宽高比相同
    _appBarHeight = ScreenUtil.screenWidth * 4 / 6;
    _getPlayListSongs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPlayListSongs() async {
    MusicDao.getPlayListDetail(widget.playlist['id'] as int).then((list) {
      if (mounted) {
        setState(() {
          _songs = list;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primarySwatch: _imageLoaded ? Colors.green : Colors.grey,
        platform: Theme.of(context).platform,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: true,
              floating: false,
              snap: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "${widget.playlist['name']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0),
                ),
                centerTitle: false,
                titlePadding:
                    EdgeInsetsDirectional.only(start: 46.0, bottom: 16.0),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Hero(
                        tag: "playListImage_${widget.playlist['id']}",
                        child: CachedNetworkImage(
                            imageUrl:
                                "${widget.playlist['coverImgUrl']}?param=600y400",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                                  'images/placeholder_play_list.jpg',
                                  fit: BoxFit.cover,
                                ),
                            height: _appBarHeight)),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return SongItemTile(this._songs, index);
                },
                childCount: _songs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
