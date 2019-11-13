import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorStyle { green, pink, purple, orange, blue }

class ColorStyleProvider with ChangeNotifier {
  static ColorStyle currentStyle;

  setStyle(ColorStyle style) {
    currentStyle = style;
    SharedPreferences.getInstance().then((prefs){
      prefs.setInt('colorStyle', style.index);
    });
    notifyListeners();
  }

  Map<ColorStyle, Map> styles = {
    ColorStyle.green: {
      'mainColor': Colors.green,
      'mainLightColor': Colors.lightGreenAccent,
      'indicatorColor': Colors.orange,
    },
    ColorStyle.pink: {
      'mainColor': Colors.pink,
      'mainLightColor': Colors.pinkAccent,
      'indicatorColor': Colors.pink,
    },
    ColorStyle.purple: {
      'mainColor': Colors.purple,
      'mainLightColor': Colors.purpleAccent,
      'indicatorColor': Colors.purple,
    },
    ColorStyle.orange: {
      'mainColor': Colors.orange,
      'mainLightColor': Colors.orangeAccent,
      'indicatorColor': Colors.orange,
    },
    ColorStyle.blue: {
      'mainColor': Colors.blue,
      'mainLightColor': Colors.blueAccent,
      'indicatorColor': Colors.blue,
    }
  };

  ColorStyle getCurrentStyle() {
    return currentStyle??ColorStyle.green;
  }

  MaterialColor getCurrentColor({String color = 'mainColor'}) {
    return getColor(getCurrentStyle(), color:color);
  }

  Color getLightColor() {
    return getColor(getCurrentStyle(), color:'mainLightColor');
  }
  
  Color getIndicatorColor() {
    return getColor(getCurrentStyle(), color:'indicatorColor');
  }

  Color getColor(ColorStyle style, {String color = 'mainColor'}) {
    Map group = styles[style];
    return group[color];
  }

  static Future<ColorStyle> initColorStyle() async {
    if (currentStyle == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int styleIndex = prefs.getInt('colorStyle') ?? 0;
      currentStyle = ColorStyle.values[styleIndex];
    }
    return currentStyle;
  }

}
