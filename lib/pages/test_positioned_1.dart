import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/test_positioned_2.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Music Player'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            /* Positioned(
          bottom: 30.0,
          child: Text("Test"),
        ), */
            Positioned(
              bottom: 30.0,
              left: 20.0,
              right: 20.0,
              child: Row(
                children: <Widget>[
                  Text("00:00",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                  Expanded(
                    child: Slider.adaptive(
                      value: 20.0,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (value) {},
                    ),
                  ),
                  Text(
                    "12:34",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
            Positioned(   // 发现一个现象：如果这儿不是Positioned那么上面的Positioned布局就会失效，报overflow异常。
              bottom: 100.0,
              left: 20.0,
              right: 20.0,
              child: RaisedButton(
              child: Text("单独的页面"),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => TestPage2()));
              },
            ))
          ],
        ));
  }
}
