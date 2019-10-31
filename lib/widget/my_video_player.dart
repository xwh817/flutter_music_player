import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/fullscreen_video_player.dart';
import 'package:video_player/video_player.dart';

import 'music_progress_bar_2.dart';

class MyVideoPlayer extends StatefulWidget {
  VideoPlayerController controller;
  PlayerState playerState;
  final Map mv;
  MyVideoPlayer({Key key, this.mv, this.controller, this.playerState:PlayerState.idle}) : super(key: key);

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

enum PlayerState { idle, loading, playing, paused }

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  PlayerState _playerState = PlayerState.idle;
  int position;
  bool isTaping = false; // 是否在手动拖动（拖动的时候进度条不要自己动
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _playerState = widget.playerState;

    if (_controller != null) {
      _setControllerListener();
    }

   print('initState ${widget.mv["name"]}, controller: ${_controller==null ?'null':_controller.hashCode}');

  }

  void _setControllerListener() {
      _controller.addListener((){
      if (!isTaping) {
        setState(() {
          position = _controller.value.position.inSeconds;
        });
      }
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
      if (_playerState == PlayerState.playing) {
        _controller.pause();
      }
      _controller.dispose();
      _controller = null;
    }
    //print('MyVideoPlayer dispose ${widget.mv["name"]}, controller: ${_controller.hashCode}');
  }

  /* @override
  void deactivate() {
    super.deactivate();
    print('MyVideoPlayer deactivate');
  } */

  
  _getMVDetail() {
    setState(() {
      _playerState = PlayerState.loading;
    });

    // 获取到视频地址之后开始播放
    MusicDao.getMVDetail(widget.mv['id']).then((url) {
      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoDemo(url: url)));
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          _play();
        });

      _setControllerListener();
    });
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
      children.add(GestureDetector(
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
          pushFullScreenWidget(context);
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
          duration: _controller.value.duration.inSeconds,
          position: position,
          onChanged: (double value) {
            setState(() {
            position = value.toInt(); 
            });
          },
          onChangeStart: (double value) {isTaping = true;},
          onChangeEnd: (double value) {
            isTaping = false;
            _controller.seekTo(Duration(seconds: value.toInt()));
          }
        ),
      )
    );
  }


  // 全屏
  Widget _buildFullScreenVideo() {
    //OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
    return Material(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(children: <Widget>[
          //FullScreenVideoPlayer(_controller),
          VideoPlayer(_controller),
          //MyVideoPlayer(mv:widget.mv, controller:_controller, playerState: this._playerState,),
          //_buildResizeButton(),
          //_buildProgressBar(),
          //_bulidPlayButton(),
        ],) 
    ));

  }

  void pushFullScreenWidget(context) {
    //SystemChrome.setPreferredOrientations(
       // [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    final TransitionRoute<void> route = PageRouteBuilder<void>(
        settings: RouteSettings(name: "Test", isInitialRoute: false),
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenVideoPlayer(_controller),
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