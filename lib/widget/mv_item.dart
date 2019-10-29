import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:video_player/video_player.dart';

class MVItem extends StatefulWidget {
  final Map mv;
  MVItem(this.mv, {Key key}) : super(key: key);

  @override
  _MVItemState createState() => _MVItemState();
}


enum PlayerState { idle, loading, playing, paused }


class _MVItemState extends State<MVItem> {
  VideoPlayerController _controller;
  PlayerState _playerState = PlayerState.idle;

  _getMVDetail() {
    MusicDao.getMVDetail(widget.mv['id']).then((url) {
      _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _playerState = PlayerState.loading;
        });
        _play();
      });
    });
  }

  void _play(){
    _controller.play().then((_){
      setState(() {
        _playerState = PlayerState.playing;
      });
    });
  }

  void _pause(){
    _controller.pause().then((_){
      setState(() {
        _playerState = PlayerState.paused;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool initialized = _controller != null && _controller.value.initialized;
    bool isPlaying = _controller != null && _controller.value.isPlaying;

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
                // 设定宽高比
                aspectRatio: 9 / 6,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        print('initialized $initialized , isPlaying $isPlaying');
                        if (_controller != null && isPlaying) {
                          _pause();
                        }
                      },
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: _playerState == PlayerState.idle
                       ? CachedNetworkImage(imageUrl: "${widget.mv['cover']}?param=600y400")
                        : _playerState == PlayerState.loading
                          ? Center(child: CircularProgressIndicator())
                          : VideoPlayer(_controller),
                    ),)
                    ,isPlaying ? Container():
                    Center(
                      child: IconButton(
                        icon: Icon(isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled),
                        iconSize: 60,
                        color: Colors.black38,
                        hoverColor: Colors.green,
                        highlightColor: Colors.red,
                        focusColor: Colors.orange,
                        onPressed: () {
                          if (_controller == null) {
                            _getMVDetail();
                          } else {
                            _play();
                          }
                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MVPlayer(mv)));
                        },
                      ),
                    )
                  ],
                )),
            Text(
              widget.mv['name'],
              style:
                  TextStyle(fontSize: 16.0, color: Colors.black, height: 2.0),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              SongUtil.getArtistNames(widget.mv),
              style:
                  TextStyle(fontSize: 14.0, color: Colors.black54, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ));
  }
}
