import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/colors.dart';

class GradientText extends StatefulWidget {
  final Widget text;
  _GradientTextState _state;
  GradientText({Key key, this.text}) : super(key: key);

  @override
  _GradientTextState createState() {
    _state = _GradientTextState();
    return _state;
  }

  int retryCount = 0;
  void setOffsetX(double offsetX) {
    if (_state == null) {
      print('_LyricPageState is null, retryCount: $retryCount');
      Future.delayed(Duration(milliseconds: 200)).then((_) {
        retryCount++;
        if (retryCount < 5) {
          setOffsetX(offsetX);
        }
      });
    } else {
      retryCount = 0;
      _state.setOffsetX(offsetX);
    }
  }
}

class _GradientTextState extends State<GradientText> {
  final Gradient gradient = LinearGradient(
    colors: [AppColors.mainLightColor, Colors.white], 
    stops: [0.5, 0.6]   // 设置渐变的起始位置
    );

  double offsetX = 0.0;

  setOffsetX(offsetX) {
    if (!mounted) return;
    //print('setOffset: $offsetX');
    setState(() {
      this.offsetX = offsetX;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 参考：https://juejin.im/post/5c860c0a6fb9a049e702ef39
    return ShaderMask(  // 遮罩层src，通过不同的BlendMode(混合模式)叠在dst上，产生不同的效果。
      shaderCallback: (bounds) {
        //print('bounds: $bounds');
        return gradient.createShader(
            Offset(-bounds.width / 2 + bounds.width * this.offsetX, 0.0) &
                bounds.size);
      },
      blendMode: BlendMode.srcIn,
      child: widget.text,
    );
  }
}
