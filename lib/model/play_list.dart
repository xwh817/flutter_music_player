
import 'package:flutter/foundation.dart';

class PlayList with ChangeNotifier{
  List songList = [];
  int index = 0;

  setPlayList(List list, int currentIndex){
    songList = list;
    index = currentIndex;
    notifyListeners();
  }

  Map getCurrentSong() {
    if (index <0 || index >= songList.length) {
      return null;
    }

    return songList[index];
  }

  Map next() {
    if (songList.length ==0) {
      return null;
    }
    index++;
    if (index >= songList.length) {
      index = 0;
    }
    notifyListeners();
    return songList[index];
  }

  Map previous() {
    if (songList.length ==0) {
      return null;
    }
    index--;
    if (index < 0) {
      index = songList.length -1;
    }
    notifyListeners();
    return songList[index];
  }

  int getIndex(){
    return index;
  }



}