import 'package:flutter/material.dart';

class WaveWidget extends StatefulWidget {
  final bool isRunning;
  WaveWidget({Key key, this.isRunning:false}) : super(key: key);

  @override
  _WaveWidgetState createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _doubleAnimation;
  AnimationController _controller;
  Function _listener;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _doubleAnimation = Tween(begin: mInitRadius, end: mInitRadius + mItemMargin).animate(_controller);
    _listener = () {
      //mFirstRadius = _controller.value; // 不要在controller取值，永远为0~1 !!!!

      /// 如果动画是repeat执行，不会触发AnimationStatus
      /// 这里用值了判断，如果比新的值大，说明是下一次开始
      if (mFirstRadius > _doubleAnimation.value) {
        if (mCircleCount < mMaxCount) {
          mCircleCount++;
        }
        //print('mCircleCount: $mCircleCount');
      }
      mFirstRadius = _doubleAnimation.value;
      if (mounted) {
        this.setState(() {});
      }
      
    };


    _doubleAnimation.addListener(_listener);

  }

  void startAnim() {
    mCircleCount = 0;
    mFirstRadius = mInitRadius;
    _controller.forward(from: 0.0);
    _controller.repeat(); // 循环动画，中途不会触发AnimationStatus变化。
  }

  void stopAnim() {
    _controller.stop();
  }

  @override
  void dispose() {
    /// 有个重要的注意
    /// 动画取消监听要放在super.dispose之前，不然就无效。
    _controller.stop();
    _controller.dispose();
    _doubleAnimation.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRunning != this.isRunning) {
      this.isRunning = widget.isRunning;
      isRunning ? startAnim() : stopAnim();
    }
    return CustomPaint(
      size: Size(maxRadius * 2, maxRadius),// 画布宽高
      painter: _WavePainter(isRunning:isRunning),
    );
  }
}

Paint mPaint;
final double mInitRadius = 30; // 第一个初始圆圈的半径
final double mItemMargin = 20; // 每圈之间的间隔
double mFirstRadius; // 第一个圆圈半径，其他扩散的依次增加。
int mCircleCount = 0; // 当前圈的个数
int mMaxCount;
final double maxRadius = 120.0;

class _WavePainter extends CustomPainter {
  int mColor = 0x888888;
  bool isRunning = false;

  _WavePainter({this.isRunning});

  void _init() {
    print('_WavePainter init');
    mPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Color(mColor);
    mMaxCount = (maxRadius - mInitRadius) ~/ mItemMargin;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) {
      _init();
    }

    if (!isRunning) {
      return;
    }

    //print('_WavePainter paint: $mFirstRadius , mCircleCount: $mCircleCount ');

    // 绘制扩散圆
    double radius = mFirstRadius;
    int i=0;
    while (i<=mCircleCount && radius <= maxRadius) {
      // 设置透明度
      int alpha = (255 * (1.0 - radius / maxRadius)).toInt();
      mPaint.color = Color(mColor).withAlpha(alpha);
      canvas.drawCircle(
            Offset(size.width / 2, size.height / 2), radius, mPaint);

      radius += mItemMargin;
      i++;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
