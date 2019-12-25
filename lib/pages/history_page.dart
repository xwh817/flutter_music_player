import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_db_history.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List _songs;

  _getSongs() async {
    HistoryDB().getHistoryList().then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _songs = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('历史播放', style: TextStyle(fontSize: 16.0),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: (){
              _clearHistory(context);
            },
          )
        ],
      ),
      body: _buildList(),
    );
  }


  Widget _buildList() {
    if (_songs == null) {
      return Container();
    }
    if (_songs.length == 0) {
      return Center(
          child: Text(
        '您还没有播放过歌曲',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, height: 1.5),
      ));
    } else {
      return ListView.builder(
        itemCount: this._songs.length,
        itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
        itemBuilder: (context, index) => SongItemTile(_songs, index),
      );
    }
  }

  
  void _clearHistory(context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              title: Text('确认', style: TextStyle(fontSize: 16.0)),
              content: Text('清除所有播放记录？', style: TextStyle(fontSize: 14.0)),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("不清除"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("清除", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    HistoryDB().clearHistory().then((re){
                      Navigator.of(context).pop();
                      _getSongs();
                    });
                  }
                ),
              ],
            ));
  }

}
