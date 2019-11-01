import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
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


    //OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);

    //_playerState = widget.playerState;

    //SystemChrome.setPreferredOrientations(
    //[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    

   //print('initState ${widget.mv["name"]}, controller: ${_controller==null ?'null':_controller.hashCode}');

   print('FullScreen initState');

   // 延时1s执行返回
  Future.delayed(Duration(seconds: 1), (){
      print('延时1s执行');
      OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
  });

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

  Future<bool> _beforePop(){
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp)
    .then((_)=>Future.delayed(Duration(microseconds: 100)))
    .then((_)=>Navigator.pop(context));
    
    return Future.value(false);
  }

  bool isLandscape = false;

  @override
  Widget build(BuildContext context) {
   print('FullScreen build');
    return WillPopScope(
      onWillPop: _beforePop,
      child: Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(children: <Widget>[
          VideoPlayer(_controller),
          //MyVideoPlayer(mv:widget.mv, controller:_controller, playerState: this._playerState,),
          //_buildResizeButton(),
          //_buildProgressBar(),
          //_bulidPlayButton(),
          /* Center(child: IconButton(icon: Icon(Icons.fullscreen, color: Colors.white,size: 48.0,), onPressed: (){
            isLandscape = !isLandscape;
            if (isLandscape) {
              OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
            } else {
              OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
            }
            
          },),) */
        ],) 
    )))
    
    ;
  }
}