import 'package:flutter/widgets.dart';

class ScreenUtil {
  static double screenWidth;
  static double screenHeight;

  static void getScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    print('屏幕宽高: ${size.width} * ${size.height}');
  }

}