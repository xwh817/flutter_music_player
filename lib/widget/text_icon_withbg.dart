import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/colors.dart';
import 'package:flutter_music_player/widget/tap_anim_widget.dart';

class TextIconWithBg extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onPressed;
  const TextIconWithBg({Key key, this.icon, this.title, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TapAnim(
            onPressed: this.onPressed,
            child: Container(
              margin: EdgeInsets.only(top: 12.0, bottom: 8.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.mainColor),
              child: Icon(icon, color: Colors.white, size: 24.0),
            )),
        Text(
          title,
          style: TextStyle(fontSize: 14.0, color: Colors.black87),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
