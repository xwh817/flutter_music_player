import 'package:flutter/material.dart';
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
      ..add(SongList())
      ..add(PlayList())
      ..add(RecommendPage())
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
