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
        }
      }
    });
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
      print(e);
    }

    return position;
  }
}

class LyricItem {
  int index;
  int position;
  String content;

  LyricItem(this.index, this.position, this.content);
}
