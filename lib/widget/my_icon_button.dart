import 'package:flutter/material.dart';

class MyIconButton extends StatefulWidget {
  final Function onTap;
  List<IconData> icons;
  final IconData icon;
  final int iconIndex;
  final double size;
  final Color colorNormal;
  final Color colorPressed;
  MyIconButton(
      {Key key,
      this.icons,
      this.icon,
      this.iconIndex: 0,
      this.size: 24,
      this.onTap,
      this.colorNormal: Colors.white70,
      this.colorPressed: Colors.green})
      : super(key: key){
        // 只有一张图片时
        if (icons == null && icon!=null) {
          icons = [icon];
        }
      }

  @override
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController _controller;
  int iconIndex = 0;
  bool isAnimRunning = false; // 动画中途不要被打断。

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
        if (widget.icons.length > 1) {
          int nextIndex = iconIndex + 1;
          if (nextIndex >= widget.icons.length) {
            nextIndex = 0;
          }
          setState(() {
            iconIndex = nextIndex;
          });

          print('Anim completed, iconIndex: $iconIndex ');
        }
        //动画执行结束时反向执行动画
        _controller.reverse();
      } else if (status == AnimationStatus.reverse) {
        print('Anim reverse, iconIndex: $iconIndex ');
        isAnimRunning = false;
      }

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('_controller.value: $_controller.value');


    print('IconIndex: $iconIndex , widgetIconIndex: ${widget.iconIndex}, isRunning: $isAnimRunning');

    if (!isAnimRunning && widget.iconIndex != iconIndex) {
      iconIndex = widget.iconIndex;
    } 

    return InkWell(
        onTap: () {
          widget.onTap();
          _controller.forward();
          isAnimRunning = true;
        },
        child: Transform.scale(
            scale: 1.0 - _controller.value * 0.2,
            child: Icon(widget.icons[iconIndex],
                size: widget.size,
                color: widget.colorNormal.withOpacity(1.0 - _controller.value))));
  }

}
