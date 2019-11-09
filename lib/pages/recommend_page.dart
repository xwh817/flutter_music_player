import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';
import 'package:flutter_music_player/pages/search_page.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';
import 'package:flutter_music_player/widget/search_bar.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import '../dao/music_163.dart';

class RecommendPage extends StatefulWidget {
  RecommendPage({Key key}) : super(key: key);

  _RecommendPageState createState() => _RecommendPageState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class _RecommendPageState extends State<RecommendPage> {
  List _newSongs = [];
  List _topSongs = [];
  final double _appBarHeight = 200.0;
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 等待两个异步任务
    Future.wait([
      MusicDao.getNewSongs(),
      MusicDao.getTopSongs(0),
    ]).then((results) {
      setState(() {
        _newSongs = results[0].sublist(0, 5);
        _topSongs = results[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _topSongs.length == 0
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            key: _scaffoldKey,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: _appBarHeight,
                  pinned: true,
                  floating: false,
                  titleSpacing: 36.0,
                  snap: false,
                  title: InkWell(
                    onTap: (){
                      NavigatorUtil.pushFade(context, SearchPage());
                    },
                    child: SearchBar(enable: false),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Swiper(
                          autoplay: true,
                          itemHeight: 200,
                          autoplayDisableOnInteraction: false,
                          itemBuilder: (BuildContext context, int index) {
                            Map song = _newSongs[index];
                            String picUrl = SongUtil.getSongImage(song, width:600, height:300);
                            return GestureDetector(
                              onTap: () => PlayerPage.gotoPlayer(context, list:_newSongs, index:index),
                              child: CachedNetworkImage(
                                imageUrl: picUrl,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          itemCount: _newSongs.length,
                          pagination: new SwiperPagination(),
                        ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return SongItemTile(this._topSongs, index);
                    },
                    childCount: _topSongs.length,
                  ),
                ),
              ],
            ),
          );
  }

}
