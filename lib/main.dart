import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/test_lyric_page.dart';
import 'package:flutter_music_player/pages/test_positioned_1.dart';
import 'package:flutter_music_player/pages/test_scroll_position.dart';
import 'pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
      //home: TestLyricPage(),
      //home: TestPage(),
    );
  }
}
