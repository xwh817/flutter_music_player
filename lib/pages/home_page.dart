import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/favorite_page.dart';
import 'package:flutter_music_player/utils/network_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/floating_player.dart';
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
    print('HomePage dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('HomePage deactive');
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
    print('HomePage build');

    // 获取屏幕大小,用于界面适配
    ScreenUtil.getScreenSize(context);

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: pages,
        physics: NeverScrollableScrollPhysics(), // 设置为不能滚动
      ),
      bottomNavigationBar: BottomTabs(this._currentIndex, this._tapCallback),
      floatingActionButton: FloatingPlayer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _RightFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _RightFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width * 3 /4;
    final double fabY = (scaffoldGeometry.scaffoldSize.height -
            scaffoldGeometry.floatingActionButtonSize.width) / 4 * 2.8;

    return Offset(fabX, fabY);
  }

  @override
  String toString() => 'FloatingActionButtonLocation.rightFloating';
}
