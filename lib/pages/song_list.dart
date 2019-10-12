import 'package:flutter/material.dart';

class SongList extends StatefulWidget {
  SongList({Key key}) : super(key: key);

  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
       children: <Widget>[         // 列表组件数组，这里有三个子Widget
              new Container(        // 子元素
                width:180.0,
                color: Colors.lightBlue,
                )
              , new Image.network(
                'http://jspang.com/static/upload/20181111/G-wj-ZQuocWlYOHM6MT2Hbh5.jpg'
                )
              , new ListTile(   // ListItem控件，一个图标一个title
                leading:new Icon(Icons.access_time),
                title:new Text('access_time')
                ),
            ],
    );
  }
}