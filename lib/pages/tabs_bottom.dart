import 'package:flutter/material.dart';


class BottomTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> tapCallback;
  
  BottomTabs(this.currentIndex, this.tapCallback);


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: tapCallback,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.green,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            title: Text('推荐'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            title: Text('歌单'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('搜索'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('历史'),
          ),
        ],
      );
  }
}