import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/fullscreen_video_player.dart';
import 'package:video_player/video_player.dart';

import 'music_progress_bar_2.dart';

class MyVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayerState playerState;
  final Map mv;
  final Function onResizePressed;
  MyVideoPlayer(
      {Key key,
      this.mv,
      this.controller,
      this.playerState: PlayerState.idle,
      this.onResizePressed})
      : super(key: key);

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
        ..initialize().then((_) {
          _play();
        });

      _initControllerListener();
    });
  }

  void _play() {
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
        _controller = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (_playerState == PlayerState.playing) {
            _pause();
          }
        },
        child: VideoPlayer(_controller),
      ));

      // 全屏按钮
      children.add(_buildResizeButton());

      // 进度条
      children.add(_buildProgressBar());
    }

    if (_playerState == PlayerState.loading) {
      children.add(Center(child: CircularProgressIndicator()));
    }

    if (_playerState == PlayerState.idle ||
        _playerState == PlayerState.paused) {
      // 播放按钮
      children.add(_bulidPlayButton());
    }

    return children;
  }

  Widget _buildResizeButton() {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Image.asset(
            'images/full_screen.png',
            width: 20.0,
          ),
          //icon: Icon(Icons.fullscreen),
          color: Colors.white,
          padding: EdgeInsets.all(8.0),
          onPressed: () {
            widget.onResizePressed(_controller);
            //pushFullScreenWidget(context);
          },
        ));
  }

  Widget _bulidPlayButton() {
    return Center(
      child: IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 66,
        color: Colors.white60,
        onPressed: () {
          if (_controller == null) {
            _getMVDetail();
          } else {
            _play();
          }
          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MVPlayer(mv)));
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 36.0,
          padding: EdgeInsets.all(8.0),
          child: MyProgressBar(
              duration: _controller.value.duration.inMilliseconds,
              position: position,
              onChanged: (double value) {
                setState(() {
                  position = value.toInt();
                });
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

  // 全屏
  Widget _buildFullScreenVideo() {
    //OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
    return Material(
        child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: <Widget>[
                //FullScreenVideoPlayer(_controller),
                VideoPlayer(_controller),
                //MyVideoPlayer(mv:widget.mv, controller:_controller, playerState: this._playerState,),
                //_buildResizeButton(),
                //_buildProgressBar(),
                //_bulidPlayButton(),
              ],
            )));
  }

  void pushFullScreenWidget(context) {
    //SystemChrome.setPreferredOrientations(
    // [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    final TransitionRoute<void> route = PageRouteBuilder<void>(
      settings: RouteSettings(name: "Test", isInitialRoute: false),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FullScreenVideoPlayer(_controller, mv: widget.mv),
      /* transitionsBuilder: (
          BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child
        ){
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-1.0, 0.0),
              end: Offset(0.0, 0.0)
            )
            .animate(CurvedAnimation(parent: animation1, curve: Curves.fastOutSlowIn)),
            child: child,
          );
        } */
    );

    route.completed.then((void value) {
      //controller.setVolume(0.0);
      //SystemChrome.setPreferredOrientations(
      //    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    });

    //controller.setVolume(1.0);
    Navigator.of(context).push(route);
  }
}
