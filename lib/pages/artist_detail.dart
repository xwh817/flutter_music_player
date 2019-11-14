import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/loading_container.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

/// 歌单详情页
///
class ArtistDetailPage extends StatefulWidget {
  final int id;
  ArtistDetailPage(this.id);

  _ArtistDetailPageState createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  double _appBarHeight;
  Map _artist;
  ScrollController _controller;

  @override
  void initState() {
    // appBar和图片宽高比相同
    _appBarHeight = ScreenUtil.screenWidth * 4 / 6;
    _controller = ScrollController();

    _getAritistDetailSongs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _getAritistDetailSongs() async {
    MusicDao.getArtistDetail(widget.id).then((re) {
      if (mounted) {
        setState(() {
          _artist = re;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _beforePop,
        child: Scaffold(
            body: CustomScrollView(
              slivers: _buildSlivers(),
              controller: _controller,
            ),
          ),
        );
  }

  List<Widget> _buildSlivers() {
    List<Widget> slivers = [];
    slivers.add(_buildAppBar());
    if (_artist != null) {
      slivers.add(_buildDesc());
      slivers.add(_buildList());
    }
    return slivers;
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: _appBarHeight,
      pinned: true,
      floating: false,
      snap: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "${_artist == null ? '' : _artist['name']}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        centerTitle: false,
        titlePadding: EdgeInsetsDirectional.only(start: 46.0, bottom: 16.0),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _artist == null
                ? Image.asset(
                    'images/placeholder_play_list.jpg',
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl:
                        "${_artist == null ? '' : _artist['image']}?param=600y400",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                          'images/placeholder_play_list.jpg',
                          fit: BoxFit.cover,
                        ),
                    height: _appBarHeight),
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

  Widget _buildDesc() {
    return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child:Text(_artist['desc'],
            style: TextStyle(color: Colors.black87, fontSize: 13.0, height: 1.2))));
  }

  Widget _buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return SongItemTile(_artist['songs'], index);
        },
        childCount: _artist['songs'].length,
      ),
    );
  }

  Future<bool> _beforePop() async {
    // 在页面退出的时候回到顶部，不然Hero动画之前的图片会空白。
    _controller.jumpTo(0);
    return true;
  }
}
