import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  WaveWidget({Key key}) : super(key: key);

  @override
  _WaveWidgetState createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _doubleAnimation;
  AnimationController _controller;
  CurvedAnimation curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.linear);
    _doubleAnimation = Tween(begin: 20.0, end: 100.0).animate(_controller);
    //_controller.repeat();


    _doubleAnimation.addListener(() {
      //mLastStartRadius = _controller.value; // 不要在controller取值!!!!
      mLastStartRadius = _doubleAnimation.value;

      if (mLastStartRadius - mInitRadius >= mItemMargin) {
        // 上一帧超过了一个间隔周期，开始新的周期
        mLastStartRadius = mInitRadius;

        mCircleCount++;
      }
      
    print('_WavePainter paint: $mLastStartRadius , mCircleCount: $mCircleCount ');

      this.setState(() {});
    });

    _doubleAnimation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      _controller.repeat(); // 动画结束时，反转从尾到头播放，结束的状态是 dismissed
    }
  }); 

    onAnimationStart();
  }

  void onAnimationStart() {
    mCircleCount = 0;
    _controller.forward(from: 0.0);
  }

  @override
  void reassemble() {
    super.reassemble();
    onAnimationStart();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 300),
      painter: _WavePainter(_doubleAnimation.value),
    );
  }
}

Paint mPaint;
double mInitRadius = 50; // 第一个初始圆圈的半径
double mItemMargin = 20; // 每圈之间的间隔
double mMaxCount = 5;
double mLastStartRadius = 50; // 上一帧起始圆圈半径
int mCircleCount = 0;

class _WavePainter extends CustomPainter {

  int mColor = 0x999999;

  _WavePainter(double radius) {
    mLastStartRadius = radius;
  }

  void _init() {
    print('_WavePainter init');
    mPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Color(0x77cdb175); //背景为纸黄色
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) {
      _init();
    }

    //print('_WavePainter paint: $mLastStartRadius , mCircleCount: $mCircleCount ');

    // 绘制扩散圆
    double radius = mLastStartRadius;
    int i=0;
    while (i <= mCircleCount) {
      // 设置透明度
      int alpha = (255 * (1.0 - i / mMaxCount)).toInt();
      if (alpha > 0) {
        mPaint.color = Color(mColor).withAlpha(alpha);
        canvas.drawCircle(
            Offset(size.width / 2, size.height / 2), radius, mPaint);
      }

      radius += mItemMargin;
      i++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
