import 'package:flutter/material.dart';

class MyIconButton extends StatefulWidget {
  final Function onTap;
  final IconData icon;
  final double size;
  final Color colorNormal;
  final Color colorPressed;
  MyIconButton(
      {Key key,
      this.icon,
      this.size: 24,
      this.onTap,
      this.colorNormal: Colors.white70,
      this.colorPressed: Colors.green})
      : super(key: key);

  @override
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  bool isTaping = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTapDown: (detail) => setState(() {
              isTaping = true;
            }),
        onTap: () {
          widget.onTap();
          setState(() {
            isTaping = false;
          });
        },
        onTapCancel: () => setState(() {
              isTaping = false;
            }),
        child: Icon(widget.icon,
            size: widget.size,
            color: isTaping ? widget.colorPressed : widget.colorNormal));
  }
}
