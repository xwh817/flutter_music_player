class SongUtil {
  static String getArtistNames(Map song) {
    String names = '';
    List arList;

    if (song.containsKey('ar')) {
      arList = song['ar'];
    } else {
      arList = song['song']['artists'];
    }

    if (arList != null) {
      bool isFirst = true;
      arList.forEach((ar) {
        if (isFirst) {
          isFirst = false;
          names = ar['name'];
        } else {
          names += " " + ar['name'];
        }
      });
    }

    // 测试，不要在build里面调用相同的函数，会频繁执行。
    print("getAritistNames: $names");
    return names;
  }

  static String getSongImage(Map song) {
    if (song.containsKey('ar')) {
      return song['al']['picUrl'];
    } else {
      return song['song']['album']['picUrl'];
    }
  }
}
