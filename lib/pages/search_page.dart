import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/search_bar.dart';
import 'package:flutter_music_player/widget/song_item_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _songs = List();
  String keywords = '';
  bool isSearching = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: SearchBar(
          controller: _controller,
          onChanged: (text) => keywords = text,
        ),
        actions: [
          MaterialButton(
            minWidth: 68,
            padding: EdgeInsets.all(0.0),
            textColor: Colors.white,
            child: Text('搜索'),
            onPressed: () {
              _search();
            },
          )
        ],
      ),
      body: isSearching
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: this._songs.length,
            itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
            itemBuilder: (context, index) => SongItemTile(_songs, index)
            ),
    );
  }

  _search() {
    if (keywords.length == 0) {
      Fluttertoast.showToast(
          msg: "请输入歌名或歌手名",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
      return;
    }
    setState(() {
      isSearching = true;
    });
    MusicDao.search(keywords).then((result) {
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {
        isSearching = false;
        _songs = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }
}
