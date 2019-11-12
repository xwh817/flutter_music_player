import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_music_player/model/play_list.dart';
import 'package:flutter_music_player/model/song_util.dart';

enum PlayerState { loading, playing, paused, stopped, completed }

class MusicListener {
  Function getName;
  Function onLoading;
  Function onStart;
  Function onPosition;
  Function onStateChanged;
  Function onError;
  MusicListener(
      {this.getName,
      this.onLoading,
      this.onStart,
      this.onPosition,
      this.onStateChanged,
      this.onError});
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

  MusicController() {
    if (audioPlayer == null) {
      init();
    }
  }

  void addMusicListener(MusicListener listener) {
    print('addMusicListener');
    if (!this.musicListeners.contains(listener)) {
      this.musicListeners.add(listener);
    }
  }

  void removeMusicListener(MusicListener listener) {
    print('removeMusicListener');
    this.musicListeners.remove(listener);
  }

  void notifyMusicListeners(Function event) {
    //print('notifyMusicListeners, musicListeners: ${musicListeners.length}, event:$event.');
    musicListeners.forEach((listener) => event(listener));
  }

  void init() {
    audioPlayer = new AudioPlayer();
    playList = PlayList();

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      position = p.inMilliseconds;
      notifyMusicListeners((listener) => listener.onPosition(position));
    });
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((event) {
      print(
          "AudioPlayer onPlayerStateChanged, last state: $playerState, currentState: $event");

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

  void setPlayList(List list, int currentIndex) {
    playList.setPlayList(list, currentIndex);
    notifyListeners();
  }

  Future startSong() async {
    Map newSong = getCurrentSong();
    if (newSong == null) {
      return;
    }

    // 是否将要播放的歌曲就是当前歌曲
    bool isContinue = song != null && song['id'] == newSong['id'];
    if (!isContinue) {
      song = newSong;
    }

    notifyMusicListeners((listener) => listener.onLoading());

    if (isContinue) {
      play(path: this.url);
    } else {  // 如果是播放新歌，就重新获取播放地址。
      SongUtil.getPlayPath(song).then((playPath) {
      play(path: playPath);
    });
    }
    
  }

  Future play({String path}) async {
    if (path == null && this.url == null) {
      print('Error: empty url!');
      return;
    }
    // 如果参数url为空，或者和之前一样，说明是继续播放当前url
    bool isContinue = path == null || path == this.url;
    if (!isContinue) {
      this.url = path;
      if (playerState != PlayerState.loading) {
        await audioPlayer.stop(); // 注意这儿要用await，不然异步到后面，状态会不对。
      }
      // 不是继续播放，就进入加载状态
      duration = 0;
      notifyMusicListeners(
          (listener) => listener.onStateChanged(PlayerState.loading));
    }

    if (path != null && path == this.url && playerState == PlayerState.paused) {
      print('播放相同的歌曲，从暂停界面切换过来，继续暂停。 path: $path , url: $url ');
      pause();
      notifyMusicListeners((listener) => listener.onStart(duration));
      notifyMusicListeners((listener) => listener.onPosition(position));
    } else {
      bool isLocal = !this.url.startsWith('http');
      print("start play: $url , isLocal: $isLocal, playerState: $playerState ");
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
      notifyMusicListeners(
          (listener) => listener.onStateChanged(PlayerState.stopped));
    }
  }
}
