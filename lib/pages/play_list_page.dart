import 'package:flutter/material.dart';
/// 歌单页
/// 笔记：在state里面获取widget中定义的变量使用widget.playlist

class PlayListPage extends StatefulWidget {
  final Map playlist;
  PlayListPage({Key key, @required this.playlist}) : super(key: key);

  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music PlayList'),
      ),
      body: Center(child: Text("${widget.playlist['name']}"),),
    );
  }
}