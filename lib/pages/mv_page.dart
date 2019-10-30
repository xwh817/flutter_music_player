import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/widget/mv_item.dart';

class MVPage extends StatefulWidget {
  MVPage({Key key}) : super(key: key);

  @override
  _MVPageState createState() => _MVPageState();
}

class _MVPageState extends State<MVPage> {
  List _mvList = List();

  _getMVList() async {
    await MusicDao.getMVList().then((result) {
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
        : CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text('MV'),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) => MVItem(this._mvList[index]),
                    childCount: _mvList.length),
              )
            ],
          );

    /* SafeArea(
      child: ListView.separated(
        itemCount: this._mvList.length,
        //itemExtent: 70.0, // 设定item的高度，这样可以减少高度计算。
        itemBuilder: (context, index) => MVItem(this._mvList[index]),
        separatorBuilder: (context, index) => Divider(
          color: Color(0x0f000000),
          height: 8.0, // 间隔的高度
          thickness: 6.0, // 绘制的线的厚度
        ),
      ),
    ); */
  }
}
