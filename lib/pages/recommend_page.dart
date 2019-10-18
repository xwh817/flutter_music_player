import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../dao/music_163.dart';

class RecommendPage extends StatefulWidget {
  RecommendPage({Key key}) : super(key: key);

  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  List _songList = List();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: new Swiper(
      autoplay: true,
      itemBuilder: (BuildContext context, int index) {
        Map song = _songList[index];
        return new Image.network(
          song['song']['album']['picUrl'] + "?param=600y300",
          fit: BoxFit.cover,
        );
      },
      itemCount: _songList.length,
      pagination: new SwiperPagination(),
      control: new SwiperControl(),
    ),);
  }

  
  _getNewSongs() async {
    await MusicDao.getNewSongs().then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _songList = result;
      });
    }).catchError((e) {
      print('Failed: ${e.toString()}');
    });
  }

  @override
  void initState() {
    super.initState();
    _getNewSongs();
  }



}
