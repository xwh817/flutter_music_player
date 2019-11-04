import 'package:flutter/material.dart';

class NavigatorUtil {
  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}