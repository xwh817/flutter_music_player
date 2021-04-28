import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/mv_item.dart';

class MVTabPage extends StatefulWidget {
  final String url;
  MVTabPage({Key key, this.url}) : super(key: key);

  @override
  _MVTabPageState createState() => _MVTabPageState();
}

class _MVTabPageState extends State<MVTabPage> {
  List _mvList = [];

  _getMVList() async {
    await MusicDao.getMVList(widget.url).then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _mvList = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    _getMVList();
  }

  @override
  Widget build(BuildContext context) {
    return _mvList.length == 0
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            cacheExtent: 10.0, // 缓存区域，滚出多远后回收item，调用其dispose
            itemCount: this._mvList.length,
            //itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
            itemBuilder: (context, index) => MVItem(this._mvList[index]),
            /* separatorBuilder: (context, index) => Divider(
              color: Color(0x0f000000),
              height: 12.0, // 间隔的高度
              thickness: 8.0, // 绘制的线的厚度
            ), */
          );
  }
}
