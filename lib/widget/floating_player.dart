import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/player_page.dart';
import 'package:provider/provider.dart';

class FloatingPlayer extends StatefulWidget {
  FloatingPlayer({Key key}) : super(key: key);

  @override
  _FloatingPlayerState createState() => _FloatingPlayerState();
}

class _FloatingPlayerState extends State<FloatingPlayer> with SingleTickerProviderStateMixin{
  AnimationController _animController;
  MusicController musicController;
  MusicListener musicListener;
  PlayerState playerState = PlayerState.playing;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(duration: const Duration(seconds: 24), vsync: this);

    musicController = Provider.of<MusicController>(context, listen: false);
    initMusicListener();
  }

  void initMusicListener() {
    musicListener = MusicListener(
        getName: () => "FloatingPlayer",
        onLoading: () {},
        onStart: (duration) {},
        onPosition: (position) {},
        onStateChanged: (state) {
          setState(() => this.playerState = state);
        },
        onError: (msg) => {});
    musicController.addMusicListener(musicListener);    
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
    musicController.dispose();
    print('FloatingPlayer dispose');
  }

  @override
  Widget build(BuildContext context) {
    Map song = musicController.getCurrentSong();

    _buildAnim();

    return FloatingActionButton(
      onPressed: () {
        if (song != null) {
          PlayerPage.gotoPlayer(context);
        }
      },
      elevation: 2.0,
      backgroundColor: Colors.black26,
      child: Container(
          padding: EdgeInsets.all(2.0),
          child: RotationTransition(
              //设置动画的旋转中心
              alignment: Alignment.center,
              //动画控制器
              turns: _animController,
              child: ClipOval(
                child: song == null
                    ? Image.asset('images/music_2.jpg', fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: SongUtil.getSongImage(song),
                        fit: BoxFit.cover),
              ))),
    );
  }

  void _buildAnim() {
    playerState = musicController.getCurrentState();
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
}
