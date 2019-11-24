class PlayList {
  List songList = [];
  int index = 0;

  setPlayList(List list, int currentIndex){
    songList = list;
    this.index = currentIndex;
  }

  setCurrentIndex(int index) {
    this.index = index;
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
    return songList[index];
  }

  int getIndex(){
    return this.index;
  }



}