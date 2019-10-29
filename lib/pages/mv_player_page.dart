import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:video_player/video_player.dart';

class MVPlayer extends StatefulWidget {
  final Map mv;
  MVPlayer(this.mv, {Key key}) : super(key: key);

  @override
  _MVPlayerState createState() => _MVPlayerState();
}

class _MVPlayerState extends State<MVPlayer> {
  VideoPlayerController _controller;
@override
  void initState() {
    super.initState();

    MusicDao.getMVDetail(widget.mv['id']).then((url){
       _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
        });
        _controller.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool initialized = _controller!= null && _controller.value.initialized;
    bool playing = _controller!= null && _controller.value.isPlaying;

    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Center(child: CircularProgressIndicator()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              playing
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            playing ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}