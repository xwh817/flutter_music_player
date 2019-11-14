import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/dao/music_163.dart';
import 'package:flutter_music_player/model/song_util.dart';
import 'package:flutter_music_player/pages/artist_detail.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';

class ArtistListPage extends StatefulWidget {
  ArtistListPage({Key key}) : super(key: key);

  @override
  _ArtistListPageState createState() => _ArtistListPageState();
}

class _ArtistListPageState extends State<ArtistListPage> {
  List artistList = [];
  _getSongs() async {
    await MusicDao.getArtistList().then((result) {
      // 界面未加载，返回。
      if (!mounted) return;

      setState(() {
        artistList = result;
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
        title: Text('热门歌手', style: TextStyle(fontSize: 16.0)),
      ),
      body: artistList.length == 0
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: artistList.length,
              itemBuilder: (context, index) => _buildItem(index),
              separatorBuilder: (context, index) =>
                  Divider(height: 0.5, color: Colors.black12),
            ),
    );
  }

  Widget _buildItem(int index) {
    Map artist = artistList[index];
    return ListTile(
      leading: ClipOval(
          child: CachedNetworkImage(
              imageUrl: SongUtil.getArtistImage(artist),
              placeholder: (context, url) =>
                  Image.asset('images/music_2.jpg', fit: BoxFit.cover))),
      title: Text(artist['name'], style: TextStyle(fontSize: 14.0)),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 4.0),
            width: 100,
            child: Text('单曲：${artist['musicSize']}',
                style: TextStyle(fontSize: 12.0)),
          ),
          Text(
            '专辑：${artist['albumSize']}',
            style: TextStyle(fontSize: 12.0),
          )
        ],
      ),
      onTap: () {
        NavigatorUtil.push(context, ArtistDetailPage(artist['id']));
      },
    );
  }
}
