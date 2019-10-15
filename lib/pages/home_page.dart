import 'package:flutter/material.dart';
import './tabs_bottom.dart';
import './song_list.dart';
import './play_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> pages = List();

  @override
  void initState() {
    pages
      ..add(SongList())
      ..add(PlayList())
      ..add(Center(child: Text("Pages 3")))
      ..add(Center(child: Text("Pages 4")));

    super.initState();
  }

  _tapCallback(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Music Player'),
        ),
        body: IndexedStack(children: pages, index: _currentIndex),
        bottomNavigationBar: BottomTabs(this._currentIndex, this._tapCallback));
  }
}
