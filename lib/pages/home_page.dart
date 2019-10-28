import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import './tabs_bottom.dart';
import './song_list.dart';
import './play_list.dart';
import './recommend_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> pages = List();

  final PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    pages
      ..add(RecommendPage())
      ..add(PlayList())
      ..add(SongList())
      ..add(Center(child: Text("Pages 4")));

    super.initState();
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
    final size = MediaQuery.of(context).size;
    ScreenUtil.screenWidth = size.width;
    ScreenUtil.screenHeight = size.height;
    print('屏幕宽高: ${size.width} * ${size.height}');

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
