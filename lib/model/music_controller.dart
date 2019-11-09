import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_music_player/model/play_list.dart';
import 'package:flutter_music_player/model/song_util.dart';


enum PlayerState { loading, playing, paused, stopped, completed }

class MusicListener{
  Function onLoading;
  Function onStart;
  Function onPosition;
  Function onStateChanged;
  Function onError;
  MusicListener({this.onLoading, this.onStart, this.onPosition, this.onStateChanged, this.onError});
}

class MusicController with ChangeNotifier {
  AudioPlayer audioPlayer;
  PlayList playList;

  PlayerState playerState = PlayerState.loading;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  Map song;
  int duration = 0;
  String url;
  MusicListener musicListener;

  MusicController(){
    if (audioPlayer == null) {
      init();
    }
  }

  void setMusicListener(MusicListener listener) {
    this.musicListener = listener;
  }

  void init() {

    audioPlayer = new AudioPlayer();
    playList = PlayList();

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      int milliseconds = p.inMilliseconds;
      musicListener?.onPosition(milliseconds);
    });
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((event) {
      print("AudioPlayer onPlayerStateChanged, last state: $playerState");
        
       if (event == AudioPlayerState.PLAYING) {
         playerState = PlayerState.playing;
        if (duration == 0) {
          duration = audioPlayer.duration.inMilliseconds;
          musicListener?.onStart(duration);
          print("AudioPlayer start, duration:$duration");
        }
      } else if (event == AudioPlayerState.PAUSED) {
        playerState = PlayerState.paused;
      } else if (event == AudioPlayerState.STOPPED) {
        playerState = PlayerState.stopped;
      } else if (event == AudioPlayerState.COMPLETED) {
        playerState = PlayerState.completed;
        print('播放结束');
        onComplete();
      }
      musicListener?.onStateChanged(playerState);
      print("AudioPlayer onPlayerStateChanged: $playerState");
    }, onError: (msg) {
      musicListener?.onError(msg);
      print("AudioPlayer onError: $msg");
    });
  }

  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
  }

  void setPlayList(List list, int currentIndex){
    playList.setPlayList(list, currentIndex);
  }

  Future startSong() async {
    song = getCurrentSong();
    if (song == null) {
      return;
    }

    this.musicListener?.onLoading();
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
    bool isContinue = path == null;
    if (!isContinue) {
      this.url = path;
      if (playerState != PlayerState.loading) {
        audioPlayer.stop();
        duration = 0;
        musicListener?.onStateChanged(PlayerState.loading);
      }
    }

    bool isLocal = !this.url.startsWith('http');
    print("start play: $url , isLocal: $isLocal, playerState: $playerState ");

    await audioPlayer.play(this.url, isLocal: isLocal);
  }

  Future pause() async {
    await audioPlayer.pause();
  }

  Future seek(double millseconds) async {
    await audioPlayer.seek(millseconds / 1000);
    if (playerState == PlayerState.paused) {
      //play();
    }
  }

  Future stop() async {
    await audioPlayer.stop();
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

  void onComplete() {
    Map nextSong = next();
    if (nextSong == null) {
      musicListener?.onStateChanged(PlayerState.stopped);
    }
  }

}