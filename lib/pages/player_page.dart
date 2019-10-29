import 'dart:async';
import 'dart:ui';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/lyric_widget.dart';

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
  int position = 0;
  bool isMuted = false;
  PlayerState playerState;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  bool isTaping = false; // 是否在手动拖动进度条（拖动的时候播放进度条不要自己动）
  String songImage;
  String artistNames;
  LyricPage lyricPage;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(duration: const Duration(seconds: 16), vsync: this);
    _animController.addStatusListener((status) {
      print("RotationTransition: $status");
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        //_animController.reset();
        //_animController.forward();
      }
    });

    int imageSize = ScreenUtil.screenWidth * 2 ~/ 3;
    // 不要把函数调用放在build之中，不然每次刷新都会调用！！
    songImage =
        SongUtil.getSongImage(widget.song) + "?param=${imageSize}y$imageSize";
    artistNames = SongUtil.getArtistNames(widget.song);
    //lyricPage = LyricPage();

    initAudioPlayer();

    url =
        "https://music.163.com/song/media/outer/url?id=${widget.song['id']}.mp3 ";
    play(url: url);

    MusicDao.getLyric(widget.song['id']).then((result) {
      //print(result.getItemsString());
      //lyricPage.updateLyric(result);
      setState(() {
        lyricPage = LyricPage(lyric: result);
      });
    });
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      int seconds = p.inSeconds;
      if (!isTaping) {
        setState(() => position = seconds);
      }
      lyricPage?.updatePosition(seconds);
    });
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      print("AudioPlayer onPlayerStateChanged, last state: $playerState");
      if (s == AudioPlayerState.PLAYING) {
        if (duration == 0) {
          setState(() => duration = audioPlayer.duration.inSeconds);
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

  Future play({String url}) async {
    print("start play: $url");
    if (url != null) {
      this.url = url;
    }

    setState(() {
      playerState = PlayerState.loading;
    });

    await audioPlayer.play(this.url);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future seek(double seconds) async {
    await audioPlayer.seek(seconds);
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
    final ThemeData theme = Theme.of(context);

    //print("Widget build: state: $playerState");
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
      /* appBar: AppBar(
        title: Text('Flutter Music Player'),
      ), */
      body: Stack(children: <Widget>[
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
                trailing: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print("${context.size.height}");
                  },
              )),
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
              child: lyricPage ??
                  Text('歌词加载中...',
                      style: TextStyle(color: Colors.white30, fontSize: 13.0)),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 48.0),
                child: Row(
                  children: <Widget>[
                    _getTimeText(position),
                    Expanded(
                      child: SliderTheme(
                        data: theme.sliderTheme.copyWith(
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 18.0),
                        ),
                        child: Slider.adaptive(
                          value: position.toDouble(),
                          min: 0.0,
                          max: duration == 0 ? 1.0 : duration.toDouble(),
                          onChanged: (double value) {
                            setState(() {
                              position = value.toInt();
                            });
                          },
                          onChangeStart: (double value) {
                            isTaping = true;
                          },
                          onChangeEnd: (double value) {
                            double seekPosition = value;
                            seek(seekPosition);
                            isTaping = false;
                            setState(() {
                              position = seekPosition.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                    _getTimeText(duration),
                  ],
                )),
          ],
        )),
      ]),
    );
  }

  Widget _getTimeText(int seconds) {
    return Container(
      width: 38.0, // 定宽，防止拖动时候字符长度变化引起抖动
      child: Text(_getFormatTime(seconds),
          maxLines: 1, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  String _getFormatTime(int seconds) {
    int minute = seconds ~/ 60;
    int hour = minute ~/ 60;
    String strHour = hour == 0 ? '' : '$hour:';
    return "$strHour${_getTimeString(minute % 60)}:${_getTimeString(seconds % 60)}";
  }

  String _getTimeString(int value) {
    return value > 9 ? "$value" : "0$value";
  }
}
