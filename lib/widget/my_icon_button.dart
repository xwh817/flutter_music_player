import 'package:flutter/material.dart';

/// 点击会有动画的按钮，并支持图片切换。
class MyIconButton extends StatefulWidget {
  final Function onPressed;
  final List<IconData> icons;
  final IconData icon;
  final int iconIndex;
  final double size;
  final Color color;
  final bool animEnable;

  ///   * [icon], 如果只需要展示一张图片。
  ///   * [icons], 如果要展示多张图片，点击时会依次向后切换。
  MyIconButton(
      {Key key,
      this.icon,
      this.icons,
      this.iconIndex: 0,
      this.size: 24,
      this.onPressed,
      this.animEnable: true,
      this.color: Colors.white});

  @override
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController _controller;
  int iconIndex = 0;
  bool isAnimRunning = false; // 动画中途不要被打断，避免闪烁的情况。
  final double defaultOpacity = 0.8;

  @override
  void initState() {
    super.initState();
    iconIndex = widget.iconIndex;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..addListener(() {
            setState(() {});
          });

    animation = new Tween(begin: 0.0, end: 1.0).animate(_controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 如果只有一张图，不需要动画
        if (widget.icons != null && widget.icons.length > 1) {
          int nextIndex;
          if (iconIndex != widget.iconIndex) {
            nextIndex = widget.iconIndex;
          }
          setState(() {
            iconIndex = nextIndex;
          });

          //print('Anim completed, iconIndex: $iconIndex ');
        }
        //动画执行结束时反向执行动画
        _controller.reverse();
      } else if (status == AnimationStatus.reverse) {
        //print('Anim reverse, iconIndex: $iconIndex ');
        isAnimRunning = false;
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
    isAnimRunning = true;
  }

  @override
  Widget build(BuildContext context) {
    //print('IconIndex: $iconIndex , widgetIconIndex: ${widget.iconIndex}, isRunning: $isAnimRunning');

    if (!isAnimRunning && widget.iconIndex != iconIndex) {
      //iconIndex = widget.iconIndex;
      // 当外部有状态改变时，自动触发动画
      startAnim();
    }

    return GestureDetector(
        onTap: () {
          if (widget.animEnable) {
            startAnim();
          }
          widget.onPressed();
        },
        child: Transform.scale(
            scale: 1.0 - _controller.value * 0.2,
            child: Icon(
                widget.icons == null ? widget.icon : widget.icons[iconIndex],
                size: widget.size,
                color: widget.color
                    .withOpacity((1.0 - _controller.value) * defaultOpacity))));
  }
}
