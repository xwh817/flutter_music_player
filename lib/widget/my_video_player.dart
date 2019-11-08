import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/video_controller.dart';
import 'package:flutter_music_player/widget/my_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'music_progress_bar_2.dart';

class MyVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerState playerState;
  final Map mv;
  final Function onResizePressed;
  final Function onShowButtons;
  final bool isFullScreen;
  MyVideoPlayer(
      {Key key,
      this.mv,
      this.controller,
      this.playerState: PlayerState.idle,
      this.onResizePressed,
      this.onShowButtons,
      this.isFullScreen: false});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

enum PlayerState { idle, loading, playing, paused }

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  PlayerState _playerState = PlayerState.idle;
  int position;
  bool isTaping = false; // 是否在手动拖动（拖动的时候进度条不要自己动
  VideoPlayerController _controller;
  bool isFromOtherPage = false;
  VoidCallback videoListener;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _playerState = widget.playerState;

    // 如果controller来自其他页面，那么退出的时候就不要把它销毁了，不然上个页面播不了了。
    isFromOtherPage = widget.controller != null;

    // 从其他页面而来，继续播放，现成的controller，但要添加进度监听。
    if (isFromOtherPage) {
      _initControllerListener();
    }
  }

  void _initControllerListener() {
    videoListener = () {
      if (!isTaping) {
        setState(() {
          position = _controller.value.position.inMilliseconds;
        });
      }
    };

    _controller.addListener(videoListener);
  }

  // 获取视频播放地址
  _getMVDetail() {
    setState(() {
      _playerState = PlayerState.loading;
    });

    // 获取到视频地址之后开始播放
    MusicDao.getMVDetail(widget.mv['id']).then((url) {
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) => _play());

      _initControllerListener();
    });
  }

  void _play() {
    // 开始播放的时候，切换全局controller，停掉上一个视频。
    Provider.of<VideoControllerProvider>(context).setController(_controller);
    _controller.play().then((_) {
      setState(() {
        _playerState = PlayerState.playing;
      });
    });
  }

  void _pause() {
    _controller.pause().then((_) {
      setState(() {
        _playerState = PlayerState.paused;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      // 去掉当前页面的进度监听
      _controller.removeListener(videoListener);

      // 视频从其他页面而来，就不要dispose，不然上个页面播不了了。
      if (!isFromOtherPage) {
        if (_playerState == PlayerState.playing) {
          _controller.pause();
        }
        _controller.dispose();
        Provider.of<VideoControllerProvider>(context).clearController(_controller);
        _controller = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 全局controller发生了变化，停掉当前的。
    if (_controller != null &&
        Provider.of<VideoControllerProvider>(context).getController() !=
            _controller) {
      _pause();
    }
    return Stack(
      children: _getWidgetsByState(),
    );
  }

  List<Widget> _getWidgetsByState() {
    List<Widget> children = [];
    if ((_playerState == PlayerState.idle ||
        _playerState == PlayerState.loading)) {
      children.add(
          CachedNetworkImage(imageUrl: "${widget.mv['cover']}?param=640y360"));
    }

    if ((_playerState == PlayerState.playing ||
        _playerState == PlayerState.paused)) {
      children.add(InkWell(
        onTap: () {
          if (isShowButton) {
            _showButtons(false);
          } else {
            _showButtonsAndAutoHide(autoHideTime, clearTimer: true);
          }
        },
        child: VideoPlayer(_controller),
      ));

      if (isShowButton) {
        // 全屏按钮
        children.add(_buildResizeButton());

        // 进度条
        children.add(_buildProgressBar());

        if (widget.isFullScreen) {}
      }
    }

    if (_playerState == PlayerState.loading) {
      children.add(Center(child: CircularProgressIndicator()));
    } else if (isShowButton) {
      // 播放按钮
      children.add(_bulidPlayButton());
    }

    return children;
  }

  final int autoHideTime = 3000;
  Timer showButtonTimer;
  bool isShowButton = true;
  int startTime = 0;
  int nextEventAfter = 0; // 如果后面点击了，就延长显示时间
  _showButtonsAndAutoHide(int milliseconds, {clearTimer: false}) {
    if (clearTimer) {
      startTime = 0;
      showButtonTimer?.cancel();
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    // 发现前面的还没结束
    if (startTime > 0) {
      nextEventAfter = now - startTime;
      //print('Timer is waiting, $nextEventAfter');
      return;
    } else {
      nextEventAfter = 0;
    }

    if (!isShowButton) {
      _showButtons(true);
    }

    //showButtonTimer?.cancel(); // 如果上一个还没结束，就取消掉。
    //print('start Timer');
    startTime = now;
    showButtonTimer = Timer(Duration(milliseconds: milliseconds), () {
      if (!mounted) {
        return;
      }
      startTime = 0;
      //print('Timer out, nextEventAfter: $nextEventAfter');

      // 如果在等待的中途再次点击了，就延长时间。
      if (nextEventAfter > 500) {
        // 太短就没必要延长了
        _showButtonsAndAutoHide(nextEventAfter);
      } else {
        _showButtons(false);
      }
    });
  }

  _showButtons(bool show) {
    if (widget.onShowButtons != null) {
      widget.onShowButtons(show);
    }
    setState(() {
      isShowButton = show;
    });
  }

  Widget _buildResizeButton() {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Image.asset(
            widget.isFullScreen
                ? 'images/full_screen_exist.png'
                : 'images/full_screen.png',
            width: 20.0,
          ),
          color: Colors.white,
          padding: EdgeInsets.all(8.0),
          onPressed: () {
            widget.onResizePressed(_controller);
          },
        ));
  }

  Widget _bulidPlayButton() {
    return Center(
      child: MyIconButton(
        icons: [Icons.pause, Icons.play_arrow],
        iconIndex: _playerState == PlayerState.playing ? 0 : 1,
        size: 66.0,
        color: Colors.white60,
        onPressed: () {
          if (_playerState == PlayerState.playing) {
            _pause();
          } else {
            if (_controller == null) {
              _getMVDetail();
            } else {
              _play();
            }
          }
          _showButtonsAndAutoHide(autoHideTime);
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    int duration = 0;
    try {
      duration = _controller.value.duration.inMilliseconds;
      if (position > duration) {
        position = 0;
      }
    } catch (e) {
      print(e);
    }
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 36.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: MyProgressBar(
              duration: duration,
              position: position,
              onChanged: (double value) {
                setState(() {
                  position = value.toInt();
                });
                // 拖动过程中不要隐藏按钮
                _showButtonsAndAutoHide(autoHideTime);
              },
              onChangeStart: (double value) {
                isTaping = true;
              },
              onChangeEnd: (double value) {
                isTaping = false;
                _controller.seekTo(Duration(milliseconds: value.toInt()));
              }),
        ));
  }
}
