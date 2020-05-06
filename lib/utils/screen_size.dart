import 'package:flutter/widgets.dart';

class ScreenSize {
  static double width;
  static double height;

  static void getScreenSize(BuildContext context) {
    MediaQueryData mediaData = MediaQuery.of(context);
    final size = mediaData.size;
    width = size.width;
    height = size.height;

    double dp = mediaData.devicePixelRatio;
    print('屏幕宽高: ${size.width} * ${size.height}, 屏幕密度：$dp ');
  }


}