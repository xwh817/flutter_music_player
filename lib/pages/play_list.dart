import 'package:flutter/material.dart';
import '../dao/music_163.dart';
import './play_list_detail.dart';

class PlayList extends StatefulWidget {
  PlayList({Key key}) : super(key: key);

  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  List _playlist = List();
  _getPlaylists() async {
    await MusicDao.getPlayList().then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

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
    print("PlayList: initState");
    _getPlaylists();
  }

  @override
  void r(PlayList oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("PlayList: didUpdateWidget");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("PlayList: didChangeDependencies");
  }

  @override
  void dispose() {
    super.dispose();
    print("PlayList: dispose");
  }

  @override
  void reassemble() {
    super.reassemble();
    print("PlayList: reassemble");
  }

  @override
  void deactivate() {
    super.deactivate();
    print("PlayList: deactivate");
  }

  Widget mWidget;
  @override
  Widget build(BuildContext context) {
    if (_playlist.length == 0) {
      // 显示进度条
      mWidget = Center(child: CircularProgressIndicator());
    } else {
      mWidget = GridView.builder(
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
      );
    }

    return mWidget;
  }

  _bulidItem(BuildContext context, int index) {
    Map play = _playlist[index];

    return new Card(
      elevation: 4.0,
      child: new Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            child: new Image.network("${play['coverImgUrl']}?param=300y300"),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0)),
            child: Container(
                width: double.infinity,
                color: Color.fromARGB(80, 0, 0, 0),
                padding: EdgeInsets.all(6.0),
                child: Text(
                  play['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                )),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  // 水波纹
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PlayListPage(playlist: play)));
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
