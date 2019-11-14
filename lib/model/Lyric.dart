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

    List<String> strItems = lyric.split('\n');
    int index = 0;
    strItems.forEach((str) {
      List<String> strs = str.split(']');
      if (strs.length == 2) {
        String time = strs[0].replaceAll('[', '');
        int position = _getPositon(time);
        String content = strs[1];
        if(position>=0) {
          this.items.add(new LyricItem(index, position, content));
          index++;
        } else {
          /* position = this.items.length > 0 ? this.items.last.position : 0;
          this.items.add(new LyricItem(index, position, str));
          index++; */
        }
      }
    });

    _initDuraton();

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
}
