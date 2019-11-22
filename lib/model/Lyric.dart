class Lyric {
  String lyric;
  List<LyricItem> items = [];

  Lyric(this.lyric) {
    build();
  }

  Lyric.empty();  // 空的构造函数

  Lyric.test() {  // test数据的构造函数
    items = List.generate(
        50, (index) => LyricItem(index, index * 1000, index.toString() * 10));
  }

  String getItemsString() {
    StringBuffer stringBuffer = new StringBuffer();
    items.forEach((LyricItem item) {
      stringBuffer.writeln(item.content);
    });

    return stringBuffer.toString();
  }

  void build() {
    if (lyric == null || lyric.length == 0) {
      return;
    }

    List<String> lines = lyric.split('\n');
    int index = 0;
    lines.forEach((line) {
      List<String> strs = line.split(']');
      if (strs.length >= 2) {   // 可能一行多句歌词的情况
        String content = strs[strs.length -1];

        for(int i=0; i<strs.length -1; i++) {
          String time = strs[i].replaceAll('[', '');
          int position = _getPositon(time);
          if(position>=0) { // 如果时间戳不正确就丢掉
            this.items.add(new LyricItem(index, position, content));
            index++;
          } else {
            //print('Lyric: 不解析的歌词：$line');
          }
        }
        
      }
    });

    _sortPosition();

    _initDuraton();

  }

  /// 对position排序，有些SB歌词时间戳居然不是有序的。
  /// 或者一行多句歌词的情况
  _sortPosition(){
    bool isSorted = true; // 大部分是有序的
    for(int i=0; i<items.length-1; i++) {
      if (items[i+1].position < items[i].position) {
        isSorted = false;
      }
    }

    if (!isSorted) {
      print('歌词无序，进行排序');
      items.sort((left, right) => left.position - right.position);

      for(int i=0; i<items.length; i++) {
        items[i].index = i;
      }
    }

  }

  _getPositon(String str) {
    int position = 0;
    try {
      List<String> strs = str.split(':');
      if (strs.length == 2) {
        int minute = int.parse(strs[0]);
        position += minute * 60 * 1000;

        List<String> secondStrs = strs[1].split('.');
        if (secondStrs.length == 2) {
          int millsecond =
              int.parse(secondStrs[0]) * 1000 + int.parse(secondStrs[1]);
          position += millsecond;
        }
      }
    } catch (e) {
      position = -1;
      //print(str + e.toString());
    }

    return position;
  }

  // 计算每段歌词的显示时间
  void _initDuraton() {
    for(int i=0; i<items.length-1; i++) {
      LyricItem item = items[i];
      item.duration = items[i+1].position - item.position;

      print(item);
    }
    // 最后一行怎样计算长度？？
    if (items.length > 1) {
      LyricItem preItem = items[items.length -2];
      LyricItem lastItem = items[items.length -1];
      int duration = preItem.duration;
      if (preItem.content.length > 0) {
        duration = duration * lastItem.content.length ~/ preItem.content.length;
      }
      lastItem.duration = duration;
    }
    
  }
}

class LyricItem {
  int index;
  int position;
  String content;
  int duration; // 歌词显示的时间长度

  LyricItem(this.index, this.position, this.content);

  @override
  String toString() {
    return '$index $position $content $duration';
  }
}
