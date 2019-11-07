import 'package:flutter/material.dart';

class MyProgressBar extends StatefulWidget {
  final Function onChanged;
  final Function onChangeStart;
  final Function onChangeEnd;

  final int duration;
  final int position;

  MyProgressBar({Key key, this.duration, this.position, this.onChanged, this.onChangeStart, this.onChangeEnd}): super(key: key);

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
    double position = widget.position == null ? 0.0 : widget.position.toDouble();
    double duration = widget.duration == null ? 0.0 : widget.duration.toDouble();


    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(_getFormatTime(widget.position),
            style: TextStyle(color: Colors.white, fontSize: 12)),
        Expanded(
          child: SliderTheme(
            data: theme.sliderTheme.copyWith(
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18.0),
            ),
            child: Slider.adaptive(
              // 歌曲切换的时候duration可能返回0，这儿要进行判断。
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
          _getFormatTime(widget.duration),
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
