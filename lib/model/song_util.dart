class SongUtil {
  static String getArtistNames(Map song) {
    String names = '';
    if (song.containsKey('ar')) {
      List arList = song['ar'];
      bool isFirst = true;
      arList.forEach((ar){
        if (isFirst) {
          isFirst = false;
          names = ar['name'];
        } else {
          names += " " + ar['name'];
        }
      });
    }
    return names;
  }
}