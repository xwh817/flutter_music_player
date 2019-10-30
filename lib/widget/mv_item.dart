import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:video_player/video_player.dart';
import 'music_progress_bar_2.dart';

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
  int position;
  bool isTaping = false; // 是否在手动拖动（拖动的时候进度条不要自己动


  _getMVDetail() {
    setState(() {
      _playerState = PlayerState.loading;
    });
    MusicDao.getMVDetail(widget.mv['id']).then((url) {
      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          _play();
        });
      _controller.addListener((){
        if (!isTaping) {
          setState(() {
            position = _controller.value.position.inSeconds;
          });
        }
        
      });
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
      _controller.pause();
      _controller.dispose();
    }
    print('MVItem dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('MVItem deactivate');
  }

  @override
  Widget build(BuildContext context) {
    //bool initialized = _controller != null && _controller.value.initialized;
    //bool isPlaying = _controller != null && _controller.value.isPlaying;

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              // 设定宽高比
              aspectRatio: 16 / 9,
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: _getWidgetsByState(),
                ),
              ),
            ),
            Text(
              widget.mv['name'],
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  height: 1.6),
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

      children.add(
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Image.asset(
                'images/full_screen.png',
                width: 20.0,
              ),
              //icon: Icon(Icons.fullscreen),
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () {},
            )),
      );

 
      //final int duration = _controller.value.duration.inSeconds;
      //final int position = _controller.value.position.inSeconds;
      children.add(
        Align(
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
          
          
        )
      );
    }

    if (_playerState == PlayerState.loading) {
      children.add(Center(child: CircularProgressIndicator()));
    }

    if (_playerState == PlayerState.idle ||
        _playerState == PlayerState.paused) {
      children.add(Center(
        child: IconButton(
          icon: Icon(Icons.play_arrow),
          iconSize: 66,
          color: Colors.white60,
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
      ));
    }

    return children;
  }
}
