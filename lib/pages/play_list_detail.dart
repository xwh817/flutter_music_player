import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/loading_container.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

/// 歌单详情页
///
class PlayListPage extends StatefulWidget {
  final Map playlist;
  PlayListPage({Key key, @required this.playlist}) : super(key: key);

  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  double _appBarHeight;
  List _songs = [];
  ScrollController _controller;

  @override
  void initState() {
    // appBar和图片宽高比相同
    _appBarHeight = ScreenUtil.screenWidth * 4 / 6;
    _controller = ScrollController();

    _getPlayListSongs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
    return WillPopScope(
        onWillPop: _beforePop,
        child: Theme(
            data: ThemeData(
              brightness: Brightness.light,
              platform: Theme.of(context).platform,
            ),
            child: Scaffold(
              key: _scaffoldKey,
              body: LoadingContainer(
                isLoading: this._songs.length == 0,
                cover: true,
                child: CustomScrollView(
                  slivers: <Widget>[
                    _buildAppBar(),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return SongItemTile(this._songs, index);
                        },
                        childCount: _songs.length,
                      ),
                    ),
                  ],
                  controller: _controller,
                ),
              ),
            )));
  }

  Widget _buildAppBar() {
    return SliverAppBar(
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
        titlePadding: EdgeInsetsDirectional.only(start: 46.0, bottom: 16.0),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
                tag: "playListImage_${widget.playlist['id']}",
                child: CachedNetworkImage(
                    imageUrl: "${widget.playlist['coverImgUrl']}?param=600y400",
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
    );
  }

  Future<bool> _beforePop() async {
    // 在页面退出的时候回到顶部，不然Hero动画之前的图片会空白。
    _controller.jumpTo(0);
    return true;
  }
}
