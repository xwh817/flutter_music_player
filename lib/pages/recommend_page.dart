import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'dart:io';

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
          fit: BoxFit.fill,
        );
      },
      itemCount: _songList.length,
      pagination: new SwiperPagination(),
      control: new SwiperControl(),
    ),);
  }

  
  _getNewSongs() async {
    var url = 'http://music.turingmao.com/personalized/newsong';
    var httpClient = new HttpClient();
    List songList;
    try {
      print("http request: $url");
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(utf8.decoder).join();
        var data = jsonDecode(json);
        songList = data['result'];
      } else {
        print('Error: Http status ${response.statusCode}');
      }

      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        _songList = songList;
      });
    } catch (exception) {
      print('Failed: ${exception.message}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getNewSongs();
  }



}
