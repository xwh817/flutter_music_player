class PlayList {
  static List<Map> songList;
  static int index;

  set (List list){
    songList = list;
  }

  Map next() {
    index++;
    if (index >= songList.length) {
      index = 0;
    }
    return songList[index];
  }

  Map previous() {
    index--;
    if (index < 0) {
      index = songList.length -1;
    }
    return songList[index];
  }



}