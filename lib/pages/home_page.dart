import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/pages/favorite_page.dart';
import 'package:flutter_music_player/utils/network_util.dart';
import 'package:flutter_music_player/utils/shared_preference_util.dart';
import 'package:flutter_music_player/utils/toast_util.dart';
import 'package:flutter_music_player/widget/floating_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_music_player/utils/screen_size.dart';
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
  List<Widget> pages = [];
  final NetworkUtil networkUtil = NetworkUtil();
  DateTime lastBackTime;
  bool showFloatPlayer = true;

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

    if (ScreenSize.width == null) {
      // 获取屏幕大小,用于界面适配(之前手动弄的，推荐下面的插件)
      ScreenSize.getScreenSize(context);
      // 屏幕适配，原理：设置设计稿尺寸，然后和设备的实际尺寸进行比较，进行缩放
      ScreenUtil.init(
          BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height),
          designSize: Size(360, 640),
          orientation: Orientation.portrait);
    }

    showFloatPlayer =
        SharedPreferenceUtil.getInstance().getBool('showFloatPlayer') ?? true;
    print('showFloatPlayer: $showFloatPlayer');

    return WillPopScope(
        onWillPop: () => _beforePop(context),
        child: Scaffold(
          body: PageView(
            controller: _controller,
            children: pages,
            physics: NeverScrollableScrollPhysics(), // 设置为不能滚动
          ),
          bottomNavigationBar: BottomTabs(
              this._currentIndex, this._tapCallback, showFloatPlayer),
          floatingActionButton: showFloatPlayer ? FloatingPlayer() : null,
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
