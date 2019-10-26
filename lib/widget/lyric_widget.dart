import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/Lyric.dart';

class LyricPage extends StatefulWidget {
  final Lyric lyric;
  LyricPage({Key key, this.lyric}) : super(key: key);
  _LyricPageState _state;

  @override
  _LyricPageState createState() {
    _state = _LyricPageState();
    return _state;
  }

  void updatePosition(int position) {
    _state?.updatePosition(position);
  }

  void updateLyric(Lyric result) {
    //_state?.updateLyric(result);
  }
}

class _LyricPageState extends State<LyricPage> {
  final double itemHeight = 30.0;
  final int visibleItemSize = 5;

  ScrollController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print('LyricPage initState');

    _controller = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyric == null) {
      return Text('歌词加载中...');
    }

    //_style.color =
    return Container(
      height: itemHeight * visibleItemSize,
      child: CustomScrollView(controller: _controller, slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
              widget.lyric.items.map((item) => _getItem(item)).toList()),
        ),
      ]),
    );
  }

  Widget _getItem(LyricItem item) {
    return Container(
        alignment: Alignment.center,
        height: itemHeight,
        child: Text(
          item.content,
          style: TextStyle(
              fontSize: 13.0,
              color: (item.index == _currentIndex)
                  ? Colors.white
                  : Colors.white60),
        ));
  }

  int getIndexOfPosition(int position) {
    int index = 0;
    for (LyricItem item in widget.lyric.items) {
      if (position * 1000 <= item.position) {
        index = index - 1;
        if (index < 0) {
          index = 0;
        }
        break;
      }
      index++;
    }
    return index;
  }

  void _scroll(int index) {
    int itemSize = widget.lyric.items.length;
    // 选中的Index是否超出边界
    if (index < 0 || index >= itemSize) {
      return;
    }

    int offset = visibleItemSize ~/ 2;
    int topIndex = index - offset; // 选中元素居中时,top的Index
    int bottomIndex = index + offset;

    setState(() {
      _currentIndex = index;
    });

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

  void scrollTo(int position) {
    double offset = position * itemHeight;
    _controller.animateTo(offset,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  void scrollBy(int by) {
    int position = _currentIndex + by;
    scrollTo(position);
  }

  // 根据歌曲播放的位置确定滚动的位置
  void updatePosition(int position) {
    int _index = getIndexOfPosition(position);
    if (_index != _currentIndex) {
      /* setState(() {
        _currentIndex = _index;
      }); */
      _currentIndex = _index;
      scrollTo(_currentIndex);
    }
  }

/*   void updateLyric(Lyric lyric) {
    setState(() {
      widget.lyric = lyric;
    });
  } */
}
