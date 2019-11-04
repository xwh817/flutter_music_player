import 'dart:async';
import 'dart:ui';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/favorite_widget.dart';
import 'package:flutter_music_player/widget/lyric_widget.dart';
import 'package:flutter_music_player/widget/music_progress_bar_2.dart';

class PlayerPage extends StatefulWidget {
  final Map song;
  PlayerPage({Key key, @required this.song}) : super(key: key);

  _PlayerPageState createState() => _PlayerPageState();
}

enum PlayerState { loading, stopped, playing, paused }

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  AudioPlayer audioPlayer;
  String url;
  int duration = 0;
  int position = 0;   // 单位：毫秒
  bool isMuted = false;
  PlayerState playerState = PlayerState.loading;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  bool isTaping = false; // 是否在手动拖动进度条（拖动的时候播放进度条不要自己动）
  String songImage;
  String artistNames;
  LyricPage _lyricPage;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(duration: const Duration(seconds: 16), vsync: this);
    _animController.addStatusListener((status) {
      print("RotationTransition: $status");
    });

    int imageSize = ScreenUtil.screenWidth * 2 ~/ 3;
    // 不要把函数调用放在build之中，不然每次刷新都会调用！！
    songImage = SongUtil.getSongImage(widget.song, size:imageSize);
    artistNames = SongUtil.getArtistNames(widget.song);

    print("imageSize of Song: $imageSize");

    initAudioPlayer();

    SongUtil.getPlayPath(widget.song).then((playPath){
      play(path: playPath);
    });

    _lyricPage = LyricPage(widget.song);

  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      int milliseconds = p.inMilliseconds;
      if (!isTaping && milliseconds <= duration) {
        _lyricPage.updatePosition(milliseconds);
        setState(() => position = milliseconds);
      }
    });
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      print("AudioPlayer onPlayerStateChanged, last state: $playerState");
      if (s == AudioPlayerState.PLAYING) {
        if (duration == 0) {
          setState(() => duration = audioPlayer.duration.inMilliseconds);
          print("AudioPlayer start, duration:$duration");
        }
        if (playerState != PlayerState.playing) {
          setState(() => playerState = PlayerState.playing);
          print("AudioPlayer playing");
        }
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
      }
      print("AudioPlayer onPlayerStateChanged: $s");
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = 0;
        position = 0;
      });
      print("AudioPlayer onError: $msg");
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  Future play({String path}) async {
    if (path == null && this.url==null) {
      print('Error: empty url!');
      return;
    }

    if (path != null) {  // 如果参数url为空，说明是继续播放当前url
      this.url = path;
    }

    bool isLocal = !this.url.startsWith('http');
    print("start play: $url , isLocal: $isLocal ");

    setState(() {
      playerState = PlayerState.loading;
    });

    await audioPlayer.play(this.url, isLocal: isLocal);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future seek(double millseconds) async {
    await audioPlayer.seek(millseconds/1000);
    if (playerState == PlayerState.paused) {
      play();
    }
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = 0;
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
      position = 0;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (playerState == PlayerState.playing) {
      if (!_animController.isAnimating) {
        _animController.forward();
        _animController.repeat();
      }
    } else {
      if (_animController.isAnimating) {
        _animController.stop();
      }
    }

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Stack(children: <Widget>[
        Container(
          // 背景图片
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CachedNetworkImage(
            imageUrl: songImage,
            fit: BoxFit.fill,
          ),
        ),
        // 高斯模糊遮罩层
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Opacity(
            opacity: 0.6,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                widget.song['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              subtitle: Text(
                artistNames,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0, color: Colors.white60),
              ),
              trailing: FavoriteIcon(widget.song) // 收藏按钮
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: RotationTransition(
                  //设置动画的旋转中心
                  alignment: Alignment.center,
                  //动画控制器
                  turns: _animController,
                  //将要执行动画的子view
                  child: ClipOval(
                      child: GestureDetector(
                    onTap: () => {
                      playerState == PlayerState.playing ? pause() : play()
                    },
                    child: CachedNetworkImage(imageUrl: songImage),
                  )))),
            Expanded(
              child: _lyricPage, // 歌词
            ),
            Container(
                padding: EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 48.0),
                child: MyProgressBar(
                duration: duration,
                position: position,
                onChanged: (double value) {
                  setState(() {
                    position = value.toInt(); 
                  });
                  _lyricPage.updatePosition(position);
                },
                onChangeStart: (double value) {isTaping = true;},
                onChangeEnd: (double value) {
                  isTaping = false;
                  seek(value);
                }
              )
            ),
          ],
        )),
      ]);
      }),
    );
  }

}
