import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/pages/player_page.dart';

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

  @override
  void initState() {
    _getPlayListSongs();
    super.initState();
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
        primarySwatch: Colors.green,
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
                  return _buildItem(context, index);
                },
                childCount: _songs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, index) {
    Map song = _songs[index];
    return new ListTile(
      title: new Text(
        "$index ${song['name']}",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: new Text(song['ar'][0]['name']),
      leading: new ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: new Image.network("${song['al']['picUrl']}?param=100y100"),
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlayerPage(song: song)));
      },
    );
  }
}
