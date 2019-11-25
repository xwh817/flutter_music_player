

import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/color_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ToastUtil {
  static showToast(BuildContext context, String msg, {toastLength= Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER}) {
    Fluttertoast.showToast(
          msg: msg,
          toastLength: toastLength,
          gravity: gravity,
          backgroundColor: Provider.of<ColorStyleProvider>(context, listen: false).getCurrentColor().withAlpha(200),
          textColor: Colors.white,
          fontSize: 14.0);
  }
}