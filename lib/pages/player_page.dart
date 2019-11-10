import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/dao/music_db.dart';
import 'package:flutter_music_player/model/music_controller.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/utils/colors.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/favorite_widget.dart';
import 'package:flutter_music_player/widget/lyric_widget.dart';
import 'package:flutter_music_player/widget/music_progress_bar_2.dart';
import 'package:flutter_music_player/widget/my_icon_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  //PlayerPage({Key key}) : super(key: key);
  // 将默认构造函数私有化
  PlayerPage._();

  // 外部跳转统一经过这儿
  static void gotoPlayer(BuildContext context, {List list, int index}) {
    if (list != null) {
      Provider.of<MusicController>(context).setPlayList(list, index);
    }
    NavigatorUtil.push(context, PlayerPage._());
  }

  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animController;
  PlayerState playerState = PlayerState.loading;

  Map song;
  String url;
  int duration = 0;
  int position = 0; // 单位：毫秒

  bool isTaping = false; // 是否在手动拖动进度条（拖动的时候播放进度条不要自己动）
  int imageSize;
  String songImage;
  String artistNames;
  LyricPage _lyricPage;
  MusicController musicController;
  MusicListener musicListener;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(duration: const Duration(seconds: 24), vsync: this);
    _animController.addStatusListener((status) {
      print("RotationTransition: $status");
    });

    imageSize = ScreenUtil.screenHeight ~/ 3;
    if (imageSize == 0) {
      imageSize = 250;
    }

    _lyricPage = LyricPage();

    musicController = Provider.of<MusicController>(context, listen: false);
    initMusicListener();

    /* this.position = musicController.getPosition();
    if (this.position > 0) {
      print("Continue playing");
      _onStartLoading();
      musicController.play();
    } else {
      musicController.startSong();
    } */
    musicController.startSong();
  }

  _onStartLoading() {
    song = musicController.getCurrentSong();
    // 不要把函数调用放在build之中，不然每次刷新都会调用！！
    songImage = SongUtil.getSongImage(song, size: imageSize);
    artistNames = SongUtil.getArtistNames(song);

    print("StartSong: $song， imageSize: $imageSize");

    if (songImage == null || songImage.isEmpty) {
      MusicDao.getSongDetail(song['id'].toString()).then((songDetail) {
        // 异步任务要判断mouted，可能结果返回时界面关闭了。
        if (mounted && songDetail != null) {
          setState(() {
            songImage = SongUtil.getSongImage(songDetail, size: imageSize);
          });
          song['imageUrl'] = SongUtil.getSongImage(songDetail, size: 0);
          print('getSongDetail: $songImage');
          MusicDB().updateFavorite(song);
        }
      });
    }

    setState(() {
      position = 0;
    });

    _lyricPage.updateSong(song);
  }

  void initMusicListener() {
    musicListener = MusicListener(
        getName: () => "PlayerPage",
        onLoading: () => _onStartLoading(),
        onStart: (duration) {
          setState(() => this.duration = duration);
        },
        onPosition: (position) {
          //print('MusicListener in PlayerPager, position: $position, duration: $duration');
          if (!isTaping) {
            // 如果手指拖动，就不通过播放器更新状态，以免抖动。
            _lyricPage.updatePosition(position);
            setState(() => this.position = position);
          }
        },
        onStateChanged: (state) {
          setState(() => this.playerState = state);
        },
        onError: (msg) => _onError(msg));

    musicController.addMusicListener(musicListener);
  }

  void _onError(msg) {
    /* try {
      Map json = jsonDecode(msg);
      if (json['what'] == 1) {
      }
    } catch (e) {
      print('onError: $msg ');
    } */

    setState(() {
      playerState = PlayerState.stopped;
      duration = 0;
      position = 0;
    });
    print("AudioPlayer onError: $msg");

    Fluttertoast.showToast(
        msg: "歌曲播放失败！",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppColors.toastBackground,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    musicController.removeMusicListener(musicListener);
    super.dispose();
  }

  // 将要播放和正在播放，用于播放按钮的状态控制。
  // 中途切歌会调用一下stoppted
  bool isGoingPlaying() {
    return playerState != PlayerState.paused;
  }

  Widget _buildTitle() {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          song['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        subtitle: Text(
          artistNames,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.0, color: Colors.white60),
        ),
        trailing: FavoriteIcon(song) // 收藏按钮
        );
  }

  Widget _getSongImage(BoxFit fit) {
    return songImage == null || songImage.isEmpty
        ? _getPlaceHolder(fit)
        : CachedNetworkImage(
            width: imageSize.toDouble(),
            height: imageSize.toDouble(),
            imageUrl: songImage,
            fit: fit,
            placeholder: (context, url) => _getPlaceHolder(fit),
          );
  }

  Widget _getPlaceHolder(BoxFit fit) {
    return Image.asset(
      'images/music_2.jpg',
      width: imageSize.toDouble(),
      height: imageSize.toDouble(),
      fit: fit,
    );
  }

  Widget _buildCDCover() {
    return Container(
        width: 60.0,
        height: 60.0,
        child: Container(
            margin: EdgeInsets.all(18.0),
            /* decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(
              width: 0.5,
              color: Colors.black45,
            ),
            shape: BoxShape.circle) */
            child: ClipOval(child: Container(color: Colors.black54))
            /* BlurOvalWidget(
              sigma: 1.0,
              color:Colors.grey.shade700,
              child: SizedBox(width: 20, height: 20,) ),*/
            ),
        decoration: BoxDecoration(
            color: Colors.white38,
            border: Border.all(
              width: 0.5,
              color: Colors.black45,
            ),
            shape: BoxShape.circle));
  }

  Widget _buildProgressIndicator() {
    return playerState == PlayerState.loading
        ? SizedBox(
            width: imageSize.toDouble(),
            height: imageSize.toDouble(),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.lightGreenAccent),
              strokeWidth: 2.0,
            ))
        : SizedBox(width: 0.0);
  }

  Widget _buildMusicCover() {
    return Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            RotationTransition(
              //设置动画的旋转中心
              alignment: Alignment.center,
              //动画控制器
              turns: _animController,
              //将要执行动画的子view
              child: InkWell(
                  onTap: () => {
                        isGoingPlaying()
                            ? musicController.pause()
                            : musicController.play()
                      },
                  child: Hero(
                      tag: 'FloatingPlayer',
                      child: ClipOval(child: _getSongImage(BoxFit.cover)))),
            ),
            //_buildCDCover(),
            _buildProgressIndicator(),
          ],
        ));
  }

  Widget _buildLyricPage() {
    return Expanded(
      child: _lyricPage, // 歌词
    );
  }

  Widget _buildProgressBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        child: MyProgressBar(
            duration: duration,
            position: position,
            onChanged: (double value) {
              setState(() {
                position = value.toInt();
              });
              _lyricPage.updatePosition(position, isTaping: true);
            },
            onChangeStart: (double value) {
              isTaping = true;
            },
            onChangeEnd: (double value) {
              isTaping = false;
              musicController.seek(value);
            }));
  }

  Widget _buildControllerBar() {
    return Container(
        padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyIconButton(
              icon: Icons.skip_previous,
              size: 40,
              onPressed: () {
                musicController.previous();
              },
            ),
            SizedBox(width: 24.0),
            MyIconButton(
              icons: [Icons.pause, Icons.play_arrow],
              iconIndex: isGoingPlaying() ? 0 : 1,
              size: 60.0,
              onPressed: () {
                isGoingPlaying()
                    ? musicController.pause()
                    : musicController.play();
              },
            ),
            SizedBox(width: 24.0),
            MyIconButton(
              icon: Icons.skip_next,
              size: 40,
              onPressed: () {
                musicController.next();
              },
            )
          ],
        ));
  }

  void _buildAnim() {
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

  @override
  Widget build(BuildContext context) {
    _buildAnim();

    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return Stack(children: <Widget>[
          // 背景图片
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _getSongImage(BoxFit.fill),
          ),
          // 高斯模糊遮罩层
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Opacity(
              opacity: 0.6,
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
          SafeArea(
              child: Column(
            children: <Widget>[
              _buildTitle(),
              _buildMusicCover(),
              _buildLyricPage(),
              _buildProgressBar(),
              _buildControllerBar(),
            ],
          )),
          /* playerState == PlayerState.loading
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      SizedBox(height: 2.0, child: LinearProgressIndicator()))
              : Container(), */
        ]);
      }),
    );
  }
}
