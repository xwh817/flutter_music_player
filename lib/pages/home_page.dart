import 'package:flutter/material.dart';
import './tabs_bottom.dart';
import './song_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {  
  int _currentIndex = 0;
  List<Widget> pages = List();

  @override
  void initState() {
    pages..add(Center(
          child:Text(
          "Pages 1"
        )))
        ..add(Center(
          child:Text(
          "Pages 2"))
          )
        ..add(Center(
          child:Text(
          "Pages 3"
        )))..add(SongList());

    super.initState();
    
  }
  
  _tapCallback(int index){
    setState(() {
     _currentIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Music Player'),
        ),
      body: this.pages[this._currentIndex],
      bottomNavigationBar: BottomTabs(this._currentIndex, this._tapCallback)
    );
  }
}
