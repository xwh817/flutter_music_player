import 'package:flutter/material.dart';
import 'package:flutter_music_player/widget/text_icon.dart';


class BottomTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> tapCallback;
  
  BottomTabs(this.currentIndex, this.tapCallback);


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFFdddddd),
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextIcon(
            icon: Icons.whatshot,
            title: '推荐',
            selected: currentIndex == 0,
            onPressed: ()=>tapCallback(0),
          ),
          TextIcon(
            icon: Icons.library_music,
            title: '歌单',
            selected: currentIndex == 1,
            onPressed: ()=>tapCallback(1),
          ),
          SizedBox(width: 50.0),
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

    _buildItem(int index, IconData icon, String title) {
      return TextIcon(
            icon: icon,
            title: title,
            selected: currentIndex == index,
            onPressed: ()=>tapCallback(index),
          );
    }

/*     return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: BottomNavigationBar(
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
      ),
    ); */
  }
}