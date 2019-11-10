import 'package:flutter/material.dart';
import 'package:flutter_music_player/widget/text_icon.dart';


class BottomTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> tapCallback;
  
  BottomTabs(this.currentIndex, this.tapCallback);


  @override
  Widget build(BuildContext context) {
    return _buildBottomAppBar();
  }

  _buildBottomAppBar() {
    return BottomAppBar(
      color: Color(0xffffffff),
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextIcon(
            icon: Icons.whatshot,
            title: '发现',
            selected: currentIndex == 0,
            onPressed: ()=>tapCallback(0),
          ),
          TextIcon(
            icon: Icons.library_music,
            title: '歌单',
            selected: currentIndex == 1,
            onPressed: ()=>tapCallback(1),
          ),
          SizedBox(width: 70.0),
          TextIcon(
            icon: Icons.movie,
            title: 'MV',
            selected: currentIndex == 2,
            onPressed: ()=>tapCallback(2),
          ),
          TextIcon(
            icon: Icons.favorite,
            title: '收藏',
            selected: currentIndex == 3,
            onPressed: ()=>tapCallback(3),
          ),
        ],
      ),
    );
  }

  _buildBottomNavigationBar(){
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: tapCallback,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.green,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('推荐'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            title: Text('歌单'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            title: Text('MV'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('收藏'),
          ),
        ],
      );
  }
}