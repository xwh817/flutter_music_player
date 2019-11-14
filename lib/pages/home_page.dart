import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/pages/favorite_page.dart';
import 'package:flutter_music_player/utils/network_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/utils/toast_util.dart';
import 'package:flutter_music_player/widget/floating_player.dart';
import 'package:provider/provider.dart';
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
  DateTime lastBackTime;

  final PageController _controller = PageController(
    initialPage: 0,
  );

  void _tapCallback(int index) {
    print("HomePage: on page selected: $index");
    _controller.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    pages
      ..add(RecommendPage(tapCallback: this._tapCallback))
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

  @override
  Widget build(BuildContext context) {
    print('HomePage build');

    // 获取屏幕大小,用于界面适配
    ScreenUtil.getScreenSize(context);

    return WillPopScope(
        onWillPop: () => _beforePop(context),
        child: Scaffold(
          body: PageView(
            controller: _controller,
            children: pages,
            physics: NeverScrollableScrollPhysics(), // 设置为不能滚动
          ),
          bottomNavigationBar:
              BottomTabs(this._currentIndex, this._tapCallback),
          floatingActionButton: FloatingPlayer(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ));
  }

  Future<bool> _beforePop(BuildContext context) async {
    if (this._currentIndex != 0) {
      _tapCallback(0);
      return false;
    }

    if (lastBackTime == null ||
        DateTime.now().difference(lastBackTime) > Duration(seconds: 2)) {
      ToastUtil.showToast(context, "再按一次退出");
      lastBackTime = DateTime.now();
      return false; // 不返回
    }

    Provider.of<MusicController>(context, listen: false).dispose();
    return true;
  }
}

