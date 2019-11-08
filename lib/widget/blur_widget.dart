import 'dart:ui';

import 'package:flutter/material.dart';

/// 毛玻璃背景
class BlurOvalWidget extends StatelessWidget {
  final Widget child;
  final double padding;
  final Color color;
  final double sigma;

  BlurOvalWidget(
      {this.child,
      this.padding: 0.0,
      this.sigma: 10.0,
      this.color: Colors.white10});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: Container(
              color: color,
              padding: EdgeInsets.all(padding),
              child: child,
            ),
          ),
    );
  }
}
