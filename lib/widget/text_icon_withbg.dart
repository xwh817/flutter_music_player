import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/colors.dart';

class TextIconWithBg extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onPressed;
  const TextIconWithBg(
      {Key key, this.icon, this.title, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: this.onPressed,
        child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.mainColor),
                  padding: EdgeInsets.all(10.0),
                  child: Icon(icon, color: Colors.white, size: 24.0),
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87, height: 1.8),
                )
              ],
            ));
  }
}
