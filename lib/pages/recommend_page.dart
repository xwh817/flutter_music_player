import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db_favorite.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/history_page.dart';
import 'package:flutter_music_player/pages/player_page.dart';
import 'package:flutter_music_player/pages/search_page.dart';
import 'package:flutter_music_player/pages/setting_page.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/mv_item.dart';
import 'package:flutter_music_player/widget/play_iist_item.dart';
import 'package:flutter_music_player/widget/search_bar.dart';
import 'package:flutter_music_player/widget/song_item_grid.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import 'package:flutter_music_player/widget/text_icon_withbg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import '../dao/music_163.dart';

class RecommendPage extends StatefulWidget {
  RecommendPage({Key key}) : super(key: key);

  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  List _newSongs = [];
  List _topSongs = [];
  List _mvList = [];
  List _playList = [];
  double _appBarHeight = 200.0;
  /* static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); */

  @override
  void initState() {
    super.initState();
    // 宽高比2/1
    _appBarHeight = ScreenUtil.screenWidth / 2;

    // 等待两个异步任务
    Future.wait([
      MusicDao.getNewSongs(),
      MusicDao.getTopSongs(0),
    ]).then((results) {
      if (results[0].length > 5) {
        _newSongs = results[0].sublist(0, 5);
      }
      if (results[1].length > 18) {
        _topSongs = results[1].sublist(0, 18);
      }
      setState(() {});
    }).then((_) {
      // 第一次进来的时候，设置默认的播放列表
      MusicController musicController = Provider.of<MusicController>(context);
      if (musicController.getCurrentSong() == null) {
        FavoriteDB().getFavoriteList().then((favList) {
          List defaultList = favList.length > 0 ? favList : _topSongs;
          musicController.setPlayList(defaultList, 0);
        });
      }
    });

// TODO 后面添加： 下拉刷新，滑到下面才加载更多。
    MusicDao.getMVList(MusicDao.URL_MV_PERSONAL).then((list) {
      if (list.length > 10) {
        list = list.sublist(0, 10);
      }
      setState(() => this._mvList = list);
    });

    MusicDao.getPlayList('流行').then((list) {
      if (list.length > 16) {
        list = list.sublist(0, 16);
      }
      setState(() => this._playList = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _topSongs.length == 0
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                _buildHeader(),
                _buildCenterGrid(),
                _buildDivider(),
                _buildSubHeader('推荐单曲', Icons.music_note),
                _buildSongGrid(),
                _buildDivider(),
                _buildSubHeader('推荐歌单', Icons.library_music),
                _buildPlayListGrid(),
                _buildDivider(),
                _buildSubHeader('推荐MV', Icons.video_library),
                _buildMVList(),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: _appBarHeight,
      pinned: true,
      floating: false,
      titleSpacing: 36.0,
      snap: false,
      title: InkWell(
        onTap: () {
          NavigatorUtil.pushFade(context, SearchPage());
        },
        child: SearchBar(enable: false),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildSwiper(),
      ),
    );
  }

  Widget _buildSwiper() {
    return Swiper(
      autoplay: true,
      itemHeight: _appBarHeight,
      autoplayDisableOnInteraction: false,
      itemBuilder: (BuildContext context, int index) {
        Map song = _newSongs[index];
        String picUrl = SongUtil.getSongImage(song, width: 600, height: 300);
        return GestureDetector(
          onTap: () =>
              PlayerPage.gotoPlayer(context, list: _newSongs, index: index),
          child: CachedNetworkImage(
            imageUrl: picUrl,
            fit: BoxFit.cover,
          ),
        );
      },
      itemCount: _newSongs.length,
      pagination: new SwiperPagination(
          builder: DotSwiperPaginationBuilder(size: 8.0, activeSize: 8.0)),
    );
  }

  Widget _buildDivider() {
    // 加载普通组件到CustomScrollView，
    return SliverToBoxAdapter(
      child: Divider(
        height: 1.0,
        thickness: 1.0,
        color: Color(0x11000000),
        //indent: 16.0,
        //endIndent: 16.0,
      ),
    );
  }

  Widget _buildCenterGrid() {
    // 加载固定数量的Grid
    /*  return SliverGrid.count(crossAxisCount: 4, children: <Widget>[
      TextIconWithBg(icon: Icons.people, title: '排行', onPressed: () {}),
      TextIconWithBg(icon: Icons.person_add, title: '歌手', onPressed: () {}),
      TextIconWithBg(icon: Icons.radio, title: '电台', onPressed: () {}),
      TextIconWithBg(icon: Icons.people, title: '歌手', onPressed: () {}),
    ]); */
    return SliverToBoxAdapter(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          TextIconWithBg(icon: Icons.date_range, title: '排行', onPressed: () {}),
          TextIconWithBg(icon: Icons.people, title: '歌手', onPressed: () {}),
          TextIconWithBg(icon: Icons.history, title: '历史', onPressed: () {
            NavigatorUtil.push(context, HistoryPage());
          }),
          TextIconWithBg(icon: Icons.settings, title: '设置', onPressed: () {
            NavigatorUtil.push(context, SettingPage());
          }),
        ]));

    /* return SliverToBoxAdapter(
        child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
      TextIconWithBg(icon: Icons.people, title: '排行', onPressed: () {}),
      TextIconWithBg(icon: Icons.person_add, title: '歌手', onPressed: () {}),
      TextIconWithBg(icon: Icons.radio, title: '电台', onPressed: () {}),
      TextIconWithBg(icon: Icons.people, title: '歌手', onPressed: () {}),
    ])); */

    /*  return SliverGrid.count(crossAxisCount: 4, children: <Widget>[
      TextIconWithBg(icon: Icons.people, title: '排行', onPressed: () {}),
      TextIconWithBg(icon: Icons.person_add, title: '歌手', onPressed: () {}),
      TextIconWithBg(icon: Icons.radio, title: '电台', onPressed: () {}),
      TextIconWithBg(icon: Icons.people, title: '歌手', onPressed: () {}),
    ]); */
  }

  Widget _buildSongList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return SongItemTile(this._topSongs, index);
        },
        childCount: _topSongs.length,
      ),
    );
  }

  Widget _buildSongGrid() {
    return SliverPadding(
        padding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 10.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return SongItemOfGrid(this._topSongs, index);
            },
            childCount: _topSongs.length,
          ),
        ));
  }

  Widget _buildPlayListGrid() {
    return SliverPadding(
        padding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 10.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return PlayListItem(_playList[index]);
            },
            childCount: _playList.length,
          ),
        ));
  }

  Widget _buildSubHeader(String title, IconData icon, {String action}) {
    return SliverToBoxAdapter(
        child: Container(
      padding: EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Provider.of<ColorStyleProvider>(context).getCurrentColor(),
            size: 18.0,
          ),
          SizedBox(width: 4.0),
          Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
      /* child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          InkWell(
            child: Container(
              height: 26,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
              child: Text('更多 >'),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.green[300], width: 0.5),
                borderRadius: BorderRadius.circular(13.0),
              ),),
            onTap: () {},
          )
        ],
      ), */
    ));
  }

  Widget _buildMVList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return MVItem(_mvList[index]);
        },
        childCount: _mvList.length,
      ),
    );
  }
}
