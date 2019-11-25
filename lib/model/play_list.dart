import 'dart:math';

enum CycleType { queue, one, random }

class PlayList {
  List songList = [];
  int index = 0;
  CycleType cycleType = CycleType.queue;

  setPlayList(List list, int currentIndex) {
    songList = list;
    this.index = currentIndex;
  }

  setCurrentIndex(int index) {
    this.index = index;
  }

  Map getCurrentSong() {
    if (index < 0 || index >= songList.length) {
      return null;
    }
    return songList[index];
  }

  Map next() {
    if (songList.length == 0) {
      return null;
    }
    index++;
    if (index >= songList.length) {
      index = 0;
    }
    return songList[index];
  }

  Map previous() {
    if (songList.length == 0) {
      return null;
    }
    index--;
    if (index < 0) {
      index = songList.length - 1;
    }
    return songList[index];
  }

  Map randomNext() {
    if (songList.length == 0) {
      return null;
    }
    int rdmIndex = 0;
    if (songList.length > 1) {
      rdmIndex = Random().nextInt(songList.length);
      if (rdmIndex == index) {
        // 如果和当前index相同，就+1。
        rdmIndex++;
        if (rdmIndex >= songList.length) {
          rdmIndex = 0;
        }
      }
    }
    index = rdmIndex;
    return songList[index];
  }

  int getCurrentIndex() {
    return this.index;
  }

  void changCycleType() {
    if (cycleType == CycleType.queue) {
      cycleType = CycleType.one;
    } else if (cycleType == CycleType.one) {
      cycleType = CycleType.random;
    } else {
      cycleType = CycleType.queue;
    }
  }

  String getCycleName() {
    String cycleName;
    switch(cycleType) {
      case CycleType.queue: cycleName = '顺序播放';break;
      case CycleType.one: cycleName = '单曲循环';break;
      case CycleType.random: cycleName = '随机播放';break;
    }
    return cycleName;
  }
}
