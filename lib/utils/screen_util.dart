import 'package:flutter/widgets.dart';

class ScreenUtil {
  static double screenWidth;
  static double screenHeight;

  static void getScreenSize(BuildContext context) {
    MediaQueryData mediaData = MediaQuery.of(context);
    final size = mediaData.size;
    screenWidth = size.width;
    screenHeight = size.height;

    double dp = mediaData.devicePixelRatio;
    print('屏幕宽高: ${size.width} * ${size.height}, 屏幕密度：$dp ');
  }

}