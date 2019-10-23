import 'package:flutter/material.dart';

class TestPage2 extends StatelessWidget {
  const TestPage2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Music Player'),
        ),
        body: SafeArea(
            child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            /* Positioned(
          bottom: 30.0,
          child: Text("Test"),
        ), */
            Align(
              alignment: Alignment.bottomCenter,
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
            GestureDetector(
              child: Text("返回"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                  )),
            ),
          ],
        )));
  }
}
