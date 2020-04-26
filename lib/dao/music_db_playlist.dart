import 'package:sqflite/sqflite.dart';
import 'music_db.dart';

class PlayListDB {
  static const table_name = 't_play_list';

  /// 单例对象的写法
  // 私有静态instance
  static PlayListDB _instance;

  // 对外访问点，指向私有静态方法
  factory PlayListDB() => _getInstance();

  static PlayListDB _getInstance() {
    if (_instance == null) {
      _instance = PlayListDB._();
    }
    return _instance;
  }

  // 将默认构造函数私有化
  PlayListDB._();

  /// 在数据库onCreate的时候，创建表。
  /// 注意：onUpgrade中添加的字段要在这儿添加，不然第一次安装就没有那个字段了。
  createTable(Database db) {
    db.execute('''create table $table_name ( 
          id integer primary key, 
          name text not null,
          cover text,
          createTime integer)
    ''');
  }

  Future<int> addPlayList(Map playList) async {
    var fav = {
      'id': playList['id'],
      'name': playList['name'],
      'cover': playList['coverImgUrl'],
      // 查看sqflite文档，发现不支持DateTime字段，用int来存储。
      'createTime': DateTime.now().millisecondsSinceEpoch,
    };

    print('fav: $fav, playList:$playList');
    return (await MusicDB().getDB()).insert(table_name, fav);
  }

  Future<Map<String, dynamic>> getPlayListById(var id) async {
    Database db = await MusicDB().getDB();
    List list = await db.query(table_name, where: 'id = ?', whereArgs: [id]);
    return list.length > 0 ? list[0] : null;
  }

  Future<List<Map<String, dynamic>>> getPlayList() async {
    Database db = await MusicDB().getDB();
    List list = await db.query(table_name, orderBy: 'createTime desc');
    List playLists = list
        .map((fav) =>
            {'id': fav['id'], 'name': fav['name'], 'coverImgUrl': fav['cover']})
        .toList();

    return playLists;
  }

  Future<int> deletePlayList(var id) async {
    Database db = await MusicDB().getDB();
    int re = await db.delete(table_name, where: 'id = ?', whereArgs: [id]);
    if (re <= 0) {
      throw Exception('删除失败');
    } else {
      return re;
    }
  }

  Future<int> clearPlayList() async {
    Database db = await MusicDB().getDB();
    return await db.delete(table_name);
  }
}
