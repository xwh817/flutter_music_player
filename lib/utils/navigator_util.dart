import 'package:flutter/material.dart';
/// 页面导航
/// 可自定义切页效果
class NavigatorUtil {
  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  static void pushFade(BuildContext context, Widget page) {
    Navigator.of(context).push(CustomRouteFade(page));
  }
}

// 渐变效果
class CustomRouteFade extends PageRouteBuilder {
  final Widget widget;
  CustomRouteFade(this.widget)
      : super(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 2.0).animate(CurvedAnimation(
                    parent: animation1, curve: Curves.fastOutSlowIn)),
                child: child,
              );
            });
}
