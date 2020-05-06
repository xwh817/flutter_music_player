import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/utils/screen_size.dart';
import 'package:flutter_music_player/utils/shared_preference_util.dart';
import 'package:flutter_music_player/widget/gradient_text.dart';
import 'package:flutter_music_player/widget/tap_anim_widget.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ColorStyleProvider colorStyleProvider;
  Color mainColor;
  double itemSize;
  bool lyricMask = true;
  bool showFloatPlayer = true;

  @override
  void initState() {
    super.initState();

    itemSize = ScreenSize.width / ColorStyleProvider.styles.length - 16.0;

    lyricMask = SharedPreferenceUtil.getInstance().getBool('lyricMask') ?? true;
    showFloatPlayer =
        SharedPreferenceUtil.getInstance().getBool('showFloatPlayer') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    colorStyleProvider = Provider.of<ColorStyleProvider>(context);

    mainColor = colorStyleProvider.getCurrentColor();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('自定义设置', style: TextStyle(fontSize: 16.0)),
      ),
      body: Column(
        children: <Widget>[
          _buildTitle('皮肤颜色'),
          _buildColorSelect(),
          _buildTitle('歌词效果'),
          _buildLyricMask(),
          _buildTitle('浮动播放器'),
          _buildFloatPlayer(),
          _buildTitle('开发者选项'),
          _buildDebugs(),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(14.0, 20.0, 14.0, 0.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildColorSelect() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ColorStyle.values.map((i) => _buildColorItem(i)).toList(),
      ),
    );
  }

  Widget _buildColorItem(ColorStyle style) {
    return TapAnim(
        onPressed: () {
          colorStyleProvider.setStyle(style);
        },
        child: Container(
          width: itemSize,
          height: itemSize,
          color: colorStyleProvider.getColor(style),
        ));
  }

  Widget _buildLyricMask() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      height: 36.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          lyricMask
              ? GradientText(
                  offsetX: 0.6,
                  colorBg: Colors.black87,
                  text: Text('已开启效果', style: TextStyle(fontSize: 15.0)),
                )
              : Text(
                  '已关闭效果',
                  style: TextStyle(color: Colors.black45, fontSize: 15.0),
                ),
          Switch(
            value: lyricMask,
            activeColor: mainColor,
            onChanged: (selected) {
              lyricMask = selected;
              SharedPreferenceUtil.getInstance()
                  .setBool('lyricMask', lyricMask);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget _buildFloatPlayer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      height: 36.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            showFloatPlayer ? '已开启' : '已隐藏',
            style: TextStyle(
                color: showFloatPlayer ? mainColor : Colors.black45,
                fontSize: 15.0),
          ),
          Switch(
            value: showFloatPlayer,
            activeColor: mainColor,
            onChanged: (selected) {
              showFloatPlayer = selected;
              SharedPreferenceUtil.getInstance()
                  .setBool('showFloatPlayer', showFloatPlayer);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  
  Widget _buildDebugs() {
    bool showPerformanceOverlay = colorStyleProvider.showPerformanceOverlay;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      height: 36.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "性能调试：" + (showPerformanceOverlay ? '已开启' : '已关闭'),
            style: TextStyle(
                color: showPerformanceOverlay ? mainColor : Colors.black45,
                fontSize: 15.0),
          ),
          Switch(
            value: showPerformanceOverlay,
            activeColor: mainColor,
            onChanged: (selected) {
              colorStyleProvider.setShowPerformanceOverlay(selected);
            },
          )
        ],
      ),
    );
  }
}
