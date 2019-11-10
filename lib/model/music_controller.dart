import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_music_player/model/play_list.dart';
import 'package:flutter_music_player/model/song_util.dart';


enum PlayerState {loading, playing, paused, stopped, completed }

class MusicListener{
  //Function onPlayListChanged;
  Function getName;
  Function onLoading;
  Function onStart;
  Function onPosition;
  Function onStateChanged;
  Function onError;
  MusicListener({this.getName, this.onLoading, this.onStart, this.onPosition, this.onStateChanged, this.onError});
}

class MusicController with ChangeNotifier {
  AudioPlayer audioPlayer;
  PlayList playList;

  PlayerState playerState = PlayerState.loading;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  Map song;
  int duration = 0;
  int position = 0;
  String url;
  List<MusicListener> musicListeners = [];
  //MusicListener musicListener;


  MusicController(){
    if (audioPlayer == null) {
      init();
    }
  }

  void addMusicListener(MusicListener listener) {
    print('addMusicListener');
    //this.musicListeners.clear();
    if (!this.musicListeners.contains(listener)) {
      this.musicListeners.add(listener);
    }
    //musicListener = listener;
  }

  void removeMusicListener(MusicListener listener) {
    print('removeMusicListener');
    this.musicListeners.remove(listener);
    //musicListener = null;
  }

  void notifyMusicListeners(Function event) {
    //print('notifyMusicListeners, musicListeners: ${musicListeners.length}, event:$event.');
    musicListeners.forEach((listener) => event(listener));
    
    /* if (musicListener != null) {
      event(musicListener);
      //print('notifyMusicListeners: ${musicListener.getName()}');
    } else {
      //print('musicListener is null!!');
    } */
    
  }

  void init() {

    audioPlayer = new AudioPlayer();
    playList = PlayList();

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      position = p.inMilliseconds;
      notifyMusicListeners((listener)=>listener.onPosition(position));
    });
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((event) {
      print("AudioPlayer onPlayerStateChanged, last state: $playerState, currentState: $event");
        
       if (event == AudioPlayerState.PLAYING) {
         playerState = PlayerState.playing;
        //if (duration == 0) {
          duration = audioPlayer.duration.inMilliseconds;
          notifyMusicListeners((listener) => listener.onStart(duration));
          print("AudioPlayer start, duration:$duration");
        //}
      } else if (event == AudioPlayerState.PAUSED) {
        playerState = PlayerState.paused;
      } else if (event == AudioPlayerState.STOPPED) {
        position = 0;
        playerState = PlayerState.stopped;
      } else if (event == AudioPlayerState.COMPLETED) {
        position = 0;
        playerState = PlayerState.completed;
        print('播放结束');
        onComplete();
      }
      notifyMusicListeners((listener) => listener.onStateChanged(playerState));
      print("AudioPlayer onPlayerStateChanged: $playerState");
    }, onError: (msg) {
      notifyMusicListeners((listener) => listener.onError(msg));
      print("AudioPlayer onError: $msg");
    });
  }

  void dispose() {
    super.dispose();
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    musicListeners.clear();
    audioPlayer?.stop();
  }

  void setPlayList(List list, int currentIndex){
    playList.setPlayList(list, currentIndex);
    notifyListeners();
  }

  Future startSong() async {
    song = getCurrentSong();
    if (song == null) {
      return;
    }

    notifyMusicListeners((listener) => listener.onLoading());
    SongUtil.getPlayPath(song).then((playPath) {
      play(path: playPath);
    });

  }



  Future play({String path}) async {
    if (path == null && this.url == null) {
      print('Error: empty url!');
      return;
    }
    // 如果参数url为空，说明是继续播放当前url
    bool isContinue = path == null || path == this.url;
    if (!isContinue) {
      this.url = path;
      if (playerState != PlayerState.loading) {
        audioPlayer.stop();
        duration = 0;
        notifyMusicListeners((listener) => listener.onStateChanged(PlayerState.loading));
      }
    }

    bool isLocal = !this.url.startsWith('http');
    print("start play: $url , isLocal: $isLocal, playerState: $playerState ");

    if (path!=null && path == this.url && playerState==PlayerState.paused) {
      print('从暂停界面切换过来，继续暂停');
      pause();
      notifyMusicListeners((listener)=>listener.onStart(duration));
      notifyMusicListeners((listener)=>listener.onPosition(position));
    } else {
      await audioPlayer.play(this.url, isLocal: isLocal);
    }
    
  }

  Future pause() async {
    await audioPlayer?.pause();
  }

  Future seek(double millseconds) async {
    await audioPlayer?.seek(millseconds / 1000);
    if (playerState == PlayerState.paused) {
      //play();
    }
  }

  Future stop() async {
    await audioPlayer?.stop();
  }

  Map next() {
    Map nextSong = playList.next();
    if (nextSong != null) {
      startSong();
    }
    return nextSong;
  }

  Map previous() {
    Map prev = playList.previous();
    if (prev != null) {
      startSong();
    }
    return prev;
  }

  Map getCurrentSong() {
    return this.playList.getCurrentSong();
  }

  PlayerState getCurrentState() {
    return this.playerState;
  }

  int getPosition() {
    return this.position;
  }

  void onComplete() {
    Map nextSong = next();
    if (nextSong == null) {
      notifyMusicListeners((listener) => listener.onStateChanged(PlayerState.stopped));
    }
  }

}