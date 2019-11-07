import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/widget/my_video_player.dart';
import 'package:orientation/orientation.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Map mv;
  FullScreenVideoPlayer(this.controller, {Key key, this.mv}) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController _controller;
  PlayerState _playerState = PlayerState.playing;
  bool showButtons = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    //AutoOrientation.landscapeLeftMode();

    //OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);

    //_playerState = widget.playerState;

    //SystemChrome.setPreferredOrientations(
    //[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    //print('initState ${widget.mv["name"]}, controller: ${_controller==null ?'null':_controller.hashCode}');

    print('FullScreen initState');

    // 延时1s执行返回
    /* Future.delayed(Duration(seconds: 1), (){
      print('延时1s执行');
      OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
      isLandscape = true;
  }); */
  }

  @override
  void deactivate() {
    super.deactivate();

    print('FullScreen deactivate');
  }

  @override
  void didUpdateWidget(FullScreenVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('FullScreen didUpdateWidget');
  }

  @override
  void dispose() {
    //OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);

    super.dispose();

    //AutoOrientation.portraitUpMode();

    print('FullScreen dispose');
  }

  bool isFullScreen = false;

  Future<bool> _beforePop() {
    if (!isFullScreen) {
      return Future.value(true);
    }

    _switchScreen(false);

    // 返回false，不关闭，走上面的异步操作。
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    print('FullScreen build');
    return WillPopScope(
        onWillPop: _beforePop,
        child: Material(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Center(
                    child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: MyVideoPlayer(
                          mv: widget.mv,
                          controller: _controller,
                          playerState: this._playerState,
                          onResizePressed: (controller) {
                            _switchScreen(!isFullScreen);
                          },
                          onShowButtons: (showButtons) {
                            setState(() {
                              this.showButtons = showButtons;
                            });
                          },
                          isFullScreen: isFullScreen,
                        ))),
                this.showButtons
                    ? SafeArea(
                        child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        iconSize: 28.0,
                        padding: EdgeInsets.all(12.0),
                        onPressed: () {
                          if (isFullScreen) {
                            _switchScreen(false);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ))
                    : Container()
              ],
            )));
  }

  Future<void> _switchScreen(bool fullScreen) async {
    print('_switchScreen: $fullScreen');
    this.isFullScreen = fullScreen;
    return OrientationPlugin.forceOrientation(isFullScreen
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.portraitUp)
        .then((_) {
      // 全屏时隐藏默认的状态栏，返回时恢复
      SystemChrome.setEnabledSystemUIOverlays(
          this.isFullScreen ? [] : SystemUiOverlay.values);

      setState(() {});
    });
  }
}
