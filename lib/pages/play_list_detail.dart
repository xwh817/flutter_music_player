import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/pages/player_page.dart';
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
  final double _appBarHeight = 256.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;
  List _songs = List();
  bool _imageLoaded = true;

  @override
  void initState() {
    _getPlayListSongs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPlayListSongs() async {
    MusicDao.getPlayListDetail(widget.playlist['id'] as int).then((list) {
      setState(() {
        _songs = list;
      });
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
              pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "${widget.playlist['name']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0),
                ),
                centerTitle: false,
                titlePadding: EdgeInsetsDirectional.only(start: 42, bottom: 16),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new Image.network(
                      "${widget.playlist['coverImgUrl']}?param=900y600",
                      /* frameBuilder: (BuildContext context, Widget child,
                          int frame, bool wasSynchronouslyLoaded) {
                        print(
                            "frameBuilder: frame:$frame, wasSynchronouslyLoaded:$wasSynchronouslyLoaded");
                        return child;
                      }, */
                     /*  loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        var progress = loadingProgress == null ? 0 : loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes;
                        if (progress == 1.0) {
                          _imageLoaded = true;
                        }

                        print(
                            "loadingBuilder: child is null:${child == null}, process:${loadingProgress == null ? 0 : loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes}");
                        return child;
                      }, */
                      /* frameBuilder: (BuildContext context, Widget child,  // fadeIn渐变效果
                          int frame, bool wasSynchronouslyLoaded) {
                            print("frameBuilder: frame:$frame, wasSynchronouslyLoaded:$wasSynchronouslyLoaded");
                        if (wasSynchronouslyLoaded) {
                             animFinished = true; 
                          return child;
                        }
                        
                        _animController.forward(); 
                        return FadeTransition(opacity: _animController, child: child);
                      }, */
                      fit: BoxFit.cover,
                      height: _appBarHeight,
                    ),
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
                  return SongItemTile(this._songs[index]);
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
