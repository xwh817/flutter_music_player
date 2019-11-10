import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/pages/play_list_detail.dart';
import 'package:flutter_music_player/widget/loading_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_music_player/widget/play_iist_item.dart';

class PlayListTabPage extends StatefulWidget {
  final String type;
  PlayListTabPage({Key key, @required this.type}) : super(key: key);

  @override
  _PlayListTabPageState createState() => _PlayListTabPageState();
}

class _PlayListTabPageState extends State<PlayListTabPage> {
  List _playlist = List();

  _getPlaylists() async {
    await MusicDao.getPlayList(widget.type).then((result) {
      // 界面未加载或者已关闭，返回。
      if (!mounted) return;

      print("getPlayList result");
      setState(() {
        _playlist = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    print("PlayList: initState ${widget.type}");
    _getPlaylists();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
        isLoading: this._playlist.length == 0,
        child: GridView.builder(
          itemCount: this._playlist.length,
          padding: EdgeInsets.all(6.0), // 四周边距，注意Card也有默认的边距
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // 网格样式
              crossAxisCount: 2, // 列数
              mainAxisSpacing: 2.0, // 主轴的间距
              crossAxisSpacing: 2.0, // cross轴间距
              childAspectRatio: 1 // item横竖比
              ),
          itemBuilder: (context, index) => _bulidItem(context, index),
        ));
  }

  _bulidItem(BuildContext context, int index) {
    Map play = _playlist[index];
    return Card(
      elevation: 4.0,
      child: PlayListItem(play),
    );
  }
}
