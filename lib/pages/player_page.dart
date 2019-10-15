import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  final Map song;
  PlayerPage({Key key, @required this.song}) : super(key: key);

  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Music Player'),
      ),
      body: Center(child: Text("${widget.song['name']}"),),
    );
  }
}