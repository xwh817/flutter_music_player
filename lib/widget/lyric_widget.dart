import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/Lyric.dart';
import 'package:flutter_music_player/utils/screen_util.dart';

class LyricPage extends StatefulWidget {
  final Map song;
  _LyricPageState _state;

  LyricPage(this.song, {Key key}) : super(key: key);

  @override
  _LyricPageState createState() {
    _state = _LyricPageState();
    return _state;
  }

  // 对比发现，从外面调用触发build的次数要少，而不是从父控件传入position。
  void updatePosition(int position) {
    _state?.updatePosition(position);
  }

}

class _LyricPageState extends State<LyricPage> {
  final double itemHeight = 30.0;
  final int lyricOffset = 0; // 可能歌词出现的时间慢了一点，这儿加一个偏移时间。
  int visibleItemSize = 7;
  Lyric lyric;

  ScrollController _controller;
  int _currentIndex = 0;
  bool isTaping = false;

  @override
  void initState() {
    super.initState();

    visibleItemSize = ScreenUtil.screenHeight < 700 ? 5 : 7;
    _controller = ScrollController();

    MusicDao.getLyric(widget.song['id']).then((result) {
      setState(() {
        lyric = result;
      });
    });
    print('LyricPage initState');
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    print('LyricPage build');
    
    if (lyric == null) {
      return Text('歌词加载中...',
          style: TextStyle(color: Colors.white30, fontSize: 13.0));
    }
    if (lyric.items.length == 0) {
      return Text('...纯音乐，无歌词...',
          style: TextStyle(
            color: Colors.white30,
            fontSize: 13.0,
            height: 3,
          ));
    }

    return Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: itemHeight * 7),
          child: CustomScrollView(controller: _controller, slivers: <Widget>[
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _getItem(lyric.items[index]);
              },
              childCount: lyric.items.length,
            )),
          ]),
        ));
  }

  Widget _getItem(LyricItem item) {
    return Container(
        alignment: Alignment.center,
        height: itemHeight,
        child: Text(
          item.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 13.0,
              color: (item.index == _currentIndex)
                  ? Colors.white
                  : Colors.white60),
        ));
  }

  /// 比较播放位置和歌词时间戳，获取当前是哪条歌词。
  /// position 当前播放位置，单位：秒
  int getIndexByTime(int milliseconds) {
    int start;
    int end;
    if (_currentIndex == 0 || milliseconds >= lyric.items[_currentIndex - 1].position) {
      start = _currentIndex;
      end = lyric.items.length;
    } else {
      start = 0;
      end = _currentIndex;
    }

    int index = start;
    for (; index < end-1; index++) {
      if (lyric.items[index+1].position >= milliseconds) {
        break;
      }
    }
    return index;
  }

/*   int _getPositionByTime(int milliseconds) {
    return milliseconds + lyricOffset;
  } */

  void scrollTo(int index) {
    int itemSize = lyric.items.length;
    // 选中的Index是否超出边界
    if (index < 0 || index >= itemSize) {
      return;
    }

    int offset = (visibleItemSize - 1) ~/ 2;
    int topIndex = index - offset; // 选中元素居中时,top的Index
    int bottomIndex = index + offset;

    setState(() {
      _currentIndex = index;
    });

    if (isTaping) {
      // 如果手指按着就不滚动
      return;
    }

    // 是否需要滚动(top和bottom到边界时不滚动了)
    if (topIndex < 0 && _controller.offset <= 0) {
      return;
    }
    if (bottomIndex >= itemSize &&
        _controller.offset >= (itemSize - visibleItemSize) * itemHeight) {
      return;
    }

    _controller.animateTo(topIndex * itemHeight,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  // 根据歌曲播放的位置确定滚动的位置
  void updatePosition(int milliseconds) {
    int _index = getIndexByTime(milliseconds);
    if (_index != _currentIndex) {
      _currentIndex = _index;
      scrollTo(_currentIndex);
    }
  }
}
