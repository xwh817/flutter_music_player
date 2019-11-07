import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/dao/music_db.dart';
import 'package:flutter_music_player/model/play_list.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/favorite_widget.dart';
import 'package:flutter_music_player/widget/lyric_widget.dart';
import 'package:flutter_music_player/widget/music_progress_bar_2.dart';
import 'package:flutter_music_player/widget/my_icon_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  _PlayerPageState createState() => _PlayerPageState();
}

enum PlayerState { loading, stopped, playing, paused }

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  AudioPlayer audioPlayer;
  Map song;
  String url;
  int duration = 0;
  int position = 0; // 单位：毫秒
  bool isMuted = false;
  PlayerState playerState = PlayerState.loading;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  bool isTaping = false; // 是否在手动拖动进度条（拖动的时候播放进度条不要自己动）
  int imageSize;
  String songImage;
  String artistNames;
  LyricPage _lyricPage;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(duration: const Duration(seconds: 24), vsync: this);
    _animController.addStatusListener((status) {
      print("RotationTransition: $status");
    });

    imageSize = ScreenUtil.screenHeight ~/ 3;
    if (imageSize == 0) {
      imageSize = 250;
    }

    _lyricPage = LyricPage();

    initAudioPlayer();
    startSong();
  }

  void startSong() {
    song = Provider.of<PlayList>(context, listen: false).getCurrentSong();
    if (song == null) {
      return;
    }

    // 不要把函数调用放在build之中，不然每次刷新都会调用！！
    songImage = SongUtil.getSongImage(song, size: imageSize);
    artistNames = SongUtil.getArtistNames(song);

    print("StartSong: $song， imageSize: $imageSize");

    SongUtil.getPlayPath(song).then((playPath) {
      play(path: playPath);
    }).then((_) {
      _lyricPage.updateSong(song);
    });

    if (songImage.isEmpty) {
      MusicDao.getSongDetail(song['id'].toString()).then((songDetail) {
        // 异步任务要判断mouted，可能结果返回，但是界面关闭了。
        if (mounted && songDetail != null) {
          setState(() {
            songImage = SongUtil.getSongImage(songDetail, size: imageSize);
          });
          song['imageUrl'] = SongUtil.getSongImage(songDetail, size: 0);
          print('getSongDetail: $songImage');
          MusicDB().updateFavorite(song);
        }
      });
    }

    setState(() {
      position = 0;
    });
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
      } else if (s == AudioPlayerState.PAUSED) {
        setState(() => playerState = PlayerState.paused);
      } else if (s == AudioPlayerState.STOPPED) {
        print("AudioPlayer stopped");
      } else if (s == AudioPlayerState.COMPLETED) {
        print('播放结束');
        onComplete();
      }
      print("AudioPlayer onPlayerStateChanged: $s");
    }, onError: (msg) {
      try {
        Map json = jsonDecode(msg);
        if (json['what'] == 1) {
          Fluttertoast.showToast(
              msg: "歌曲播放失败！",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 14.0);
        }
      } catch (e) {
        print(e);
      }

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
        setState(() {
          duration = 0;
          playerState = PlayerState.loading;
        });
      }
    }

    bool isLocal = !this.url.startsWith('http');
    print("start play: $url , isLocal: $isLocal ");

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

  Map next() {
    Map nextSong = Provider.of<PlayList>(context).next();
    if (nextSong != null) {
      startSong();
    }
    return nextSong;
  }

  Map previous() {
    Map prev = Provider.of<PlayList>(context).previous();
    if (prev != null) {
      startSong();
    }
    return prev;
  }

  void onComplete() {
    Map nextSong = next();
    if (nextSong == null) {
      setState(() {
        playerState = PlayerState.stopped;
        position = 0;
      });
    }
  }

  // 将要播放和正在播放，用于播放按钮的状态控制。
  bool isGoingPlaying() {
    return playerState == PlayerState.loading ||
        playerState == PlayerState.playing;
  }

  Widget _buildTitle() {
    return ListTile(
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
          song['name'],
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
        trailing: FavoriteIcon(song) // 收藏按钮
        );
  }

  Widget _getSongImage(BoxFit fit) {
    return songImage.isEmpty
        ? Image.asset(
            'images/music_2.jpg',
            width: imageSize.toDouble(),
            height: imageSize.toDouble(),
            fit: fit,
          )
        : CachedNetworkImage(
            width: imageSize.toDouble(),
            height: imageSize.toDouble(),
            imageUrl: songImage,
            fit: fit,
          );
  }

  Widget _buildMusicCover() {
    return Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: RotationTransition(
            //设置动画的旋转中心
            alignment: Alignment.center,
            //动画控制器
            turns: _animController,
            //将要执行动画的子view
            child: ClipOval(
                child: GestureDetector(
              onTap: () => {isGoingPlaying() ? pause() : play()},
              child: _getSongImage(BoxFit.cover),
            ))));
  }

  // 进度条
  Widget _buildProgressBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        child: MyProgressBar(
            duration: duration,
            position: position,
            onChanged: (double value) {
              setState(() {
                position = value.toInt();
              });
              _lyricPage.updatePosition(position, isTaping: true);
            },
            onChangeStart: (double value) {
              isTaping = true;
            },
            onChangeEnd: (double value) {
              isTaping = false;
              seek(value);
            }));
  }

  Widget _buildControllerBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyIconButton(
              icon: Icons.skip_previous,
              size: 40,
              onTap: () {
                previous();
              },
            ),
            SizedBox(width: 24.0),
            MyIconButton(
              icons: [Icons.pause, Icons.play_arrow],
              iconIndex: isGoingPlaying() ? 0 : 1,
              size: 60.0,
              onTap: () {
                isGoingPlaying() ? pause() : play();
              },
            ),
            SizedBox(width: 24.0),
            MyIconButton(
              icon: Icons.skip_next,
              size: 40,
              onTap: () {
                next();
              },
            )
          ],
        ));
  }

  void _buildAnim() {
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
  }

  @override
  Widget build(BuildContext context) {
    _buildAnim();

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Stack(children: <Widget>[
          // 背景图片
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _getSongImage(BoxFit.fill),
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
              _buildTitle(),
              _buildMusicCover(),
              Expanded(
                child: _lyricPage, // 歌词
              ),
              _buildProgressBar(),
              _buildControllerBar(),
            ],
          )),
          playerState == PlayerState.loading
              ? Center(
                  child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ))
              : Container(),
        ]);
      }),
    );
  }
}
