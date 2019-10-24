class Lyric {
  String lyric;
  List<LyricItem> items = [];

  Lyric(this.lyric){
    build();
  }

  String getItemsString(){
    StringBuffer stringBuffer = new StringBuffer();
    items.forEach((LyricItem item){
      stringBuffer.writeln(item.content);
    });

    return stringBuffer.toString();
  }

  void build(){
    if (lyric == null || lyric.length == 0) {
      return;
    }

    List<String> strItems = lyric.split('\n');
    strItems.forEach((str){
      List<String> strs = str.split(']');
      if (strs.length ==2) {
        String time = strs[0].replaceAll('[', '');
        int positin = _getPositon(time);
        String content = strs[1];
        this.items.add(new LyricItem(positin, content));
      }
    });

  }

  _getPositon(String str) {
    int position = 0;
    List<String> strs = str.split(':');
    if(strs.length == 2){
      int minute = int.parse(strs[0]);
      position += minute * 60 * 1000;

      List<String> secondStrs = strs[1].split('.');
      if (secondStrs.length == 2) {
        int millsecond = int.parse(secondStrs[0]) * 1000 + int.parse(secondStrs[1]);
        position += millsecond;
      }
    }

    return position;
  }
}

class LyricItem {
  int position;
  String content;

  LyricItem(this.position, this.content);
}