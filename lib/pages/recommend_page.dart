import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/player_page.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../dao/music_163.dart';

class RecommendPage extends StatefulWidget {
  RecommendPage({Key key}) : super(key: key);

  _RecommendPageState createState() => _RecommendPageState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class _RecommendPageState extends State<RecommendPage> {
  List _newSongs = List();
  List _topSongs = List();
  final double _appBarHeight = 200.0;
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;


  @override
  void initState() {
    super.initState();

    // 等待两个异步任务
    Future.wait([
      MusicDao.getNewSongs(),
      MusicDao.getTopSongs(0),
    ]).then((results){
      setState(() {
        _newSongs = results[0].sublist(0, 5);
        _topSongs = results[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: false,
              //pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new Swiper(
                      autoplay: true,
                      itemHeight: 200,
                      autoplayDisableOnInteraction: false,
                      itemBuilder: (BuildContext context, int index) {
                        Map song = _newSongs[index];
                        String picUrl = song['song']['album']['picUrl'];
                        //song['al']['picUrl'] = picUrl;
                        return GestureDetector(
                          onTap: () => _onItemTap(song),
                          child: CachedNetworkImage(imageUrl: picUrl+ "?param=600y300", fit: BoxFit.cover,),
                        );
                      },
                      itemCount: _newSongs.length,
                      pagination: new SwiperPagination(),
                    ),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    /* const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ), */
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return SongItemTile(this._topSongs[index]);
                },
                childCount: _topSongs.length,
              ),
            ),
          ],
        ),
      );
  }

  
  void _onItemTap(Map song) {
    Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PlayerPage(song: song)));
  }

}
