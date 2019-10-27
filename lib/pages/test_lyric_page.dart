import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/Lyric.dart';
import 'package:flutter_music_player/widget/lyric_widget.dart';

class TestLyricPage extends StatelessWidget {
  LyricPage lyricPage;
  int index = 0;
  TestLyricPage({Key key}) : super(key: key) {
    lyricPage = LyricPage(lyric:Lyric.test());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test Scroll Position"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'up',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                index--;
                lyricPage.updatePosition(index);
              },
            ),
            FlatButton(
              child: Text(
                'down',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                index++;
                lyricPage.updatePosition(index);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black45,
          child: lyricPage,
        ));
  }
}
