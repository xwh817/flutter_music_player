import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/shared_preference_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 集齐了７色：红橙黄绿青蓝紫
enum ColorStyle { pink, orange, lime, green, blue, indigo,  purple }

class ColorStyleProvider with ChangeNotifier {
  static ColorStyle currentStyle = ColorStyle.green;
  static const pref_color = 'colorStyle';
  bool showPerformanceOverlay = false; // 是否在界面上显示性能调试层

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
    return currentStyle;
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

  setStyle(ColorStyle style) {
    currentStyle = style;
    SharedPreferenceUtil.getInstance().setInt(pref_color, style.index);
    notifyListeners();
  }

  static ColorStyle initColorStyle() {
    SharedPreferences prefs = SharedPreferenceUtil.getInstance();
    if (prefs.containsKey(pref_color)) {
      int styleIndex = prefs.getInt(pref_color);
      currentStyle = ColorStyle.values[styleIndex];
    }
    return currentStyle;
  }

  setShowPerformanceOverlay(bool visible) {
    this.showPerformanceOverlay = visible;
    notifyListeners();
  }

}
