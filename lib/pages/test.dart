import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/test_page_2.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  onChanged: (value){

                  },
                ),
              ),
              Text(
                "12:34",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
        GestureDetector(child: Text("单独的页面"),onTap: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TestPage2()));
        },)
      ],
    );
  }
}