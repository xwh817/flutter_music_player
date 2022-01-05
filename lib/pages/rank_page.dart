import 'package:flutter/material.dart';
import 'package:flutter_music_player/pages/rank_song_list.dart';
import 'package:flutter_music_player/utils/navigator_util.dart';

class RankPage extends StatefulWidget {
  RankPage({Key key}) : super(key: key);

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('排行榜', style: TextStyle(fontSize: 16.0)),
      ),
      body: ListView.separated(
        itemCount: ranks.length,
        itemBuilder: (context, index) =>
            _buildItem(ranks.entries.elementAt(index)),
        separatorBuilder: (context, index) =>
            Divider(height: 0.5, color: Colors.black12),
      ),
    );
  }

  Widget _buildItem(MapEntry entry) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20.0, top: 4.0, bottom: 4.0),
      leading: Icon(Icons.whatshot, color: Colors.deepOrangeAccent),
      title: Text(entry.value, style: TextStyle(fontSize: 14.0)),
      onTap: () {
        NavigatorUtil.push(context, RankSongList(entry.key, entry.value));
      },
    );
  }
}

Map<int, String> ranks = {
  3779629: '云音乐新歌榜',
  3778678: '云音乐热歌榜',
  2: '网易原创歌曲榜',
  3: '云音乐飙升榜',
  4: '云音乐电音榜',
  5: 'UK排行榜周榜',
  6: '美国Billboard周榜',
  7: 'KTV嗨榜',
  8: 'iTunes榜',
  9: 'Hit FM Top榜',
  10: '日本Oricon周榜',
  11: '韩国Melon排行榜周榜',
  12: '韩国Mnet排行榜周榜',
  13: '韩国Melon原声周榜',
  14: '中国TOP排行榜(港台榜)',
  15: '中国TOP排行榜(内地榜)',
  16: '香港电台中文歌曲龙虎榜',
  17: '华语金曲榜',
  18: '中国嘻哈榜',
  19: '法国 NRJ EuroHot 30周榜',
  20: '台湾Hito排行榜',
  21: 'Beatport全球电子舞曲榜',
  22: '云音乐ACG音乐榜',
  23: '云音乐说唱榜',
  24: '云音乐古典音乐榜',
  25: '云音乐电音榜',
  26: '抖音排行榜',
  27: '新声榜',
  28: '云音乐韩语榜',
  29: '英国Q杂志中文版周榜',
  30: '电竞音乐榜',
  31: '云音乐欧美热歌榜',
  32: '云音乐欧美新歌榜',
  33: '说唱TOP榜',
};
