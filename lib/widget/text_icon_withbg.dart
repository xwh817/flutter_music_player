import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:flutter_music_player/widget/tap_anim_widget.dart';
import 'package:provider/provider.dart';

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
              margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Provider.of<ColorStyleProvider>(context)
                      .getCurrentColor()),
              child: Icon(icon, color: Colors.white, size: 24.0),
            )),
        Text(
          title,
          style: TextStyle(fontSize: 13.0, color: Colors.black87),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
