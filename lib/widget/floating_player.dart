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
    print('FloatingPlayer initState');

    _animController =
        AnimationController(duration: const Duration(seconds: 16), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    print('FloatingPlayer didChangeDependencies');

    /// listen: true，当Provider中notifyListeners时，自动触发更新。
    /// 默认为true，所以在不需要自动触发更新的地方要设为false。
    initMusicListener();
  }

  void initMusicListener() {
    if (musicListener == null) {
      musicListener = MusicListener(
        getName: () => "FloatingPlayer",
        onLoading: () {},
        onStart: (duration) {},
        onPosition: (position) {},
        onStateChanged: (state) {
          setState(() => this.playerState = state);
        },
        onError: (msg) => {});
    }
    
    musicController = Provider.of<MusicController>(context, listen: true);
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
    print('FloatingPlayer build');

    Map song = musicController.getCurrentSong();

    _buildAnim();

    return Container(
      width: 70.0,
      height: 70.0,
      child:FloatingActionButton(
      onPressed: () {
        if (song != null) {
          PlayerPage.gotoPlayer(context);
        }
      },
      elevation: 2.0,
      backgroundColor: Colors.black26,
      heroTag: 'FloatingPlayer',
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
                        placeholder: (context, url) => Image.asset('images/music_2.jpg', fit: BoxFit.cover),
                        fit: BoxFit.cover),
              ))),
    ));
  }

  void _buildAnim() {
    playerState = musicController.getCurrentState();
    if (playerState == PlayerState.playing) {
      if (!_animController.isAnimating) {
        print('开始动画');
        _animController.forward();
        _animController.repeat();
      }
    } else {
      if (_animController.isAnimating) {
        print('结束动画');
        _animController.stop();
      }
    }
  }
}
