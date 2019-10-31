class SongUtil {
  static String getArtistNames(Map song) {
    if (song.containsKey('artistNames')) {
      return song['artistNames'];
    }

    String names = '';
    List arList;

    if (song.containsKey('ar')) {
      arList = song['ar'];
    } else if (song.containsKey('artists')) {
      arList = song['artists'];
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
    
    // 取了之后存下来，不用重复取了。
    song['artistNames'] = names;

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
