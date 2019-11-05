import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/favorite_page.dart';
import 'package:flutter_music_player/utils/network_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import './tabs_bottom.dart';
import './play_list_page.dart';
import './recommend_page.dart';
import 'mv_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> pages = List();
  final NetworkUtil networkUtil = NetworkUtil();


  final PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();

    pages
      ..add(RecommendPage())
      ..add(PlayListPage())
      ..add(MVPage())
      ..add(FavoritePage());

    networkUtil.initNetworkListener();
  }

  @override
  void dispose() {
    super.dispose();
    networkUtil.dispose();
  }
  

  _tapCallback(int index) {
    print("HomePage: on page selected: $index");
    _controller.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    // 获取屏幕大小,用于界面适配
    if(ScreenUtil.screenWidth == null || ScreenUtil.screenWidth == 0) {
      ScreenUtil.getScreenSize(context);
    }
  
    return Scaffold(
        /* appBar: AppBar(
          title: Text('Flutter Music Player'),
        ), */
        body: PageView(
          controller: _controller,
          children: pages,
          physics: NeverScrollableScrollPhysics(),  // 设置为不能滚动
        ),
        bottomNavigationBar: BottomTabs(this._currentIndex, this._tapCallback));
  }
}
