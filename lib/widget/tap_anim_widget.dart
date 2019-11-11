import 'package:flutter/material.dart';

/// 点击会有动画的控件
class TapAnim extends StatefulWidget {
  final Function onPressed;
  final Widget child;
  final int animDuration;

  TapAnim({this.child, this.onPressed, this.animDuration:160});

  @override
  _TapAnimState createState() => _TapAnimState();
}

class _TapAnimState extends State<TapAnim> with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: widget.animDuration))
          ..addListener(() {
            setState(() {});
          });

    animation = new Tween(begin: 0.0, end: 1.0).animate(_controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startAnim() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          startAnim();
          widget.onPressed();
        },
        child: Transform.scale(
          scale: 1.0 - _controller.value * 0.2,
          child: widget.child,
        ));
  }
}
