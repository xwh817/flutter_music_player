import 'package:flutter/material.dart';

class MyProgressBar extends StatefulWidget {
  final Function onChanged;
  final Function onChangeStart;
  final Function onChangeEnd;

  final int duration;
  final int position;

  MyProgressBar({Key key, this.duration:1, this.position:0, this.onChanged, this.onChangeStart, this.onChangeEnd}): super(key: key);

  _MyProgressBarState createState() => _MyProgressBarState();

}

class _MyProgressBarState extends State<MyProgressBar> {

  @override
  void initState() {
    super.initState();
    print('MyProgressBar initState');
  }
  
  @override
  Widget build(BuildContext context) {
    // 坑很多：Slider注意范围越界的问题，而且duration不能为0.0
    // 歌曲切换的时候duration可能返回0。
    // 播放出错的时候，可能返回负数。
    double position = widget.position <0 ? 0.0 : widget.position.toDouble();
    double duration = widget.duration <= 0 ? 1.0 : widget.duration.toDouble();
    if (position > duration) {
      position = 0;
    }
    //print('duration: $duration, position: $position');

    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(_getFormatTime(position.toInt()),
            style: TextStyle(color: Colors.white, fontSize: 12)),
        Expanded(
          child: SliderTheme(
            data: theme.sliderTheme.copyWith(
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18.0),
            ),
            child: Slider.adaptive(
              value: position,
              min: 0.0,
              max: duration,
              onChanged: (double value) {
                widget.onChanged(value);
              },
              onChangeStart: (double value) {
                widget.onChangeStart(value);
              },
              onChangeEnd: (double value) {
                widget.onChangeEnd(value);
              },
            ),
          )
        ),
        Text(
          _getFormatTime(duration.toInt()),
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  String _getFormatTime(int milliseconds) {
    if (milliseconds == null) {
      milliseconds =0;
    }
    int seconds = milliseconds ~/ 1000;
    int minute = seconds ~/ 60;
    int hour = minute ~/ 60;
    String strHour = hour == 0 ? '' : '$hour:';
    return "$strHour${_getTimeString(minute % 60)}:${_getTimeString(seconds % 60)}";
  }

  String _getTimeString(int value) {
    return value > 9 ? "$value" : "0$value";
  }
}
