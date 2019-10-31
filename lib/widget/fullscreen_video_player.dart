import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  FullScreenVideoPlayer(this.controller, {Key key}) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {

  VideoPlayerController _controller;
  //PlayerState _playerState = PlayerState.idle;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;


    //AutoOrientation.landscapeLeftMode();


    //OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);

    //_playerState = widget.playerState;

    //SystemChrome.setPreferredOrientations(
    //[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    

   //print('initState ${widget.mv["name"]}, controller: ${_controller==null ?'null':_controller.hashCode}');

   

  }

  @override
  void dispose() {
    super.dispose();

    //AutoOrientation.portraitUpMode();

  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(children: <Widget>[
          VideoPlayer(_controller),
          //MyVideoPlayer(mv:widget.mv, controller:_controller, playerState: this._playerState,),
          //_buildResizeButton(),
          //_buildProgressBar(),
          //_bulidPlayButton(),
        ],) 
    ));
  }
}