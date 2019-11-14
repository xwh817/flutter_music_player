import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorStyle { pink, orange, lime, green, blue, indigo,  purple }

class ColorStyleProvider with ChangeNotifier {
  static ColorStyle currentStyle;

  setStyle(ColorStyle style) {
    currentStyle = style;
    SharedPreferences.getInstance().then((prefs){
      prefs.setInt('colorStyle', style.index);
    });
    notifyListeners();
  }

  static final Map<ColorStyle, Map> styles = {
    ColorStyle.pink: {
      'mainColor': Colors.pink,
      'mainLightColor': Colors.pinkAccent,
      'indicatorColor': Colors.pink,
    },
    ColorStyle.orange: {
      'mainColor': Colors.deepOrange,
      'mainLightColor': Colors.deepOrangeAccent,
      'indicatorColor': Colors.orange,
    },
    ColorStyle.lime: {
      'mainColor': Colors.lightGreen,
      'mainLightColor': Colors.limeAccent,
      'indicatorColor': Colors.lime,
    },
    ColorStyle.green: {
      'mainColor': Colors.green,
      'mainLightColor': Colors.lightGreenAccent,
      'indicatorColor': Colors.orange,
    },
    ColorStyle.blue: {
      'mainColor': Colors.blue,
      'mainLightColor': Colors.blueAccent,
      'indicatorColor': Colors.blue,
    },
    ColorStyle.indigo: {
      'mainColor': Colors.indigo,
      'mainLightColor': Colors.indigoAccent,
      'indicatorColor': Colors.indigo,
    },
    ColorStyle.purple: {
      'mainColor': Colors.purple,
      'mainLightColor': Colors.purpleAccent,
      'indicatorColor': Colors.purple,
    },
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
