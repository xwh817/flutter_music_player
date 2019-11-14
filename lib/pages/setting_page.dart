import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/utils/screen_util.dart';
import 'package:flutter_music_player/widget/tap_anim_widget.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Color mainColor;
  double itemSize;

  @override
  void initState() {
    super.initState();

    itemSize = ScreenUtil.screenWidth / ColorStyleProvider.styles.length - 16.0;
  }


  @override
  Widget build(BuildContext context) {

    mainColor = Provider.of<ColorStyleProvider>(context).getCurrentColor();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('自定义设置', style: TextStyle(fontSize: 16.0)),
      ),
      body: Column(children: <Widget>[
        _buildTitle('皮肤颜色'),
        _buildColorSelect(),
      ],),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(14.0, 16.0, 14.0, 0.0),
      child: Text(title, 
      style: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),),
    );
  }
  
  Widget _buildColorSelect() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ColorStyle.values.map((i)=> _buildColorItem(i)).toList(),
      ),
    );
  }

  Widget _buildColorItem(ColorStyle style) {
    return TapAnim(
      onPressed: (){
        Provider.of<ColorStyleProvider>(context).setStyle(style);
      },
      child:Container(
      width: itemSize,
      height: itemSize,
      color: Provider.of<ColorStyleProvider>(context).getColor(style),
    ));
  }
}
