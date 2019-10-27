import 'package:flutter/material.dart';

class MusicProgressBar extends StatefulWidget {

  int position = 0;
  int duration = 0;
  bool isTaping = false; // 是否在手动拖动（拖动的时候进度条不要自己动
  Function seek;

  MusicProgressBar({Key key, this.position, this.duration, this.seek}) : super(key: key);

  _MusicProgressBarState createState() => _MusicProgressBarState();
}

class _MusicProgressBarState extends State<MusicProgressBar> {

  @override
  Widget build(BuildContext context) {
    return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(_getFormatTime(widget.position),
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                    child: Slider.adaptive(
                      value: widget.position.toDouble(),
                      min: 0.0,
                      max: widget.duration == 0 ? 1.0 : widget.duration.toDouble(),
                      onChanged: (double value) {
                        setState(() {
                          widget.position = value.toInt();
                        });
                      },
                      onChangeStart: (double value) {
                        widget.isTaping = true;
                      },
                      onChangeEnd: (double value) {
                        double seekPosition = value;
                        widget.seek(seekPosition);
                        widget.isTaping = false;
                        setState(() {
                          widget.position = seekPosition.toInt();
                        });
                      },
                    ),
                  ),
                  Text(
                    _getFormatTime(widget.duration),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              );
  }


  String _getFormatTime(int seconds) {
    int minute = seconds ~/ 60;
    int hour = minute ~/ 60;
    String strHour = hour == 0 ? '' : '$hour:';
    return "$strHour${_getTimeString(minute % 60)}:${_getTimeString(seconds % 60)}";
  }

  String _getTimeString(int value) {
    return value > 9 ? "$value" : "0$value";
  }

}