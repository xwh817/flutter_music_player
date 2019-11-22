import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/model/speech_manager.dart';
import 'package:flutter_music_player/utils/toast_util.dart';
import 'package:flutter_music_player/widget/search_bar.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import 'package:flutter_music_player/widget/wave_widget.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  final bool startSpeech;
  SearchPage({Key key, this.startSpeech: false}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _songs = List();
  String keywords = '';
  bool isSearching = false;
  bool isAnimRunning = false;
  TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.startSpeech) {
      _startSpeech();
    }
    
    AsrManager.init().then((_) => print('AsrManagerinit'));
  }

  @override
  void dispose() {
    if (isAnimRunning) {
      AsrManager.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: SearchBar(
            //text: this.keywords,
            controller: _textController,
            onChanged: (text) => keywords = text,
            onSpeechPressed: () {
              _startSpeech();
            },
          ),
          actions: [
            MaterialButton(
              minWidth: 68,
              padding: EdgeInsets.all(0.0),
              textColor: Colors.white,
              child: Text('搜索'),
              onPressed: () {
                _search();
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            isSearching
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: this._songs.length,
                    itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
                    itemBuilder: (context, index) =>
                        SongItemTile(_songs, index)),
            _buildSpeechAnim(),
          ],
        ));
  }

  Widget _buildSpeechAnim() {
    Color mainColor = Provider.of<ColorStyleProvider>(context, listen: false).getCurrentColor();
    return Align(
        alignment: Alignment.bottomCenter,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          WaveWidget(isRunning: this.isAnimRunning),
          GestureDetector(
              onLongPressStart: (detail) {
                print('onTapDown');
                HapticFeedback.vibrate();
                _startSpeech();
              },
              onTap: () {
                if (isAnimRunning) {
                  _stopSpeech();
                } else {
                  ToastUtil.showToast(context, '按住说出歌名或歌手名');
                }
              },
              onLongPressUp: () {
                _stopSpeech();
              },
              onTapCancel: () {
                _stopSpeech();
              },
              child: Container(
                height: 60.0,
                width: 60.0,
                child: Icon(Icons.mic, color: Colors.white.withOpacity(0.8), size: 36),
                decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
              ))
        ]));
  }

  _startAnim() {
    setState(() => isAnimRunning = true);
  }

  _stopAnim() {
    print('stopAnim, mounted: $mounted');
    if (mounted && isAnimRunning) {
      setState(() => isAnimRunning = false);
    }
  }

  _startSpeech() {
    _startAnim();
    AsrManager.start().then((value) {
      print('Speech result: $value');
      if (value.isNotEmpty) {
        keywords = value;
        _textController.text = value;
        this._search();
      }

      _stopAnim();
    }
    ,onError: (error){
        _stopAnim();
        ToastUtil.showToast(context, "语音识别失败");
        print("onError: $error");
      }
    );
  }

  _stopSpeech() {
    _stopAnim();
    AsrManager.stop();
  }

  _search() {
    if (keywords.length == 0) {
      ToastUtil.showToast(context, "请输入歌名或歌手名");
      return;
    }
    setState(() {
      isSearching = true;
    });
    MusicDao.search(keywords).then((result) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        isSearching = false;
        _songs = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }
}
