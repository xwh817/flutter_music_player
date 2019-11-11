import 'package:flutter_music_player/model/song_util.dart';
import 'package:sqflite/sqflite.dart';

class MusicDB {
  static const db_version = 2;
  static const db_file = 'music.db';
  static const t_favorite = 't_favorite';

  /// 单例对象的写法
  // 私有静态instance
  static MusicDB _instance;

  // 对外访问点，指向私有静态方法
  factory MusicDB() => _getInstance();

  static MusicDB _getInstance() {
    if (_instance == null) {
      _instance = MusicDB._();
    }
    return _instance;
  }

  // 将默认构造函数私有化
  MusicDB._();

  // db对象不能直接生成，第一次会报错，因为db对象是异步生成的,直接调用的时候为null。
  Database db;
  // 定义一个get方法，完美解决获取db可能为空的情况。
  Future<Database> getDB() async {
    if (db == null) {
      db = await initDB();
    }
    return db;
  }

  Future<Database> initDB() async {
    print('initDB');
    return await openDatabase(db_file, version: db_version,
        onCreate: (Database db, int version) async {
      // 初始化，创建表
      _createTableFavorite();
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // 数据库升级，修改表结构。
      if (oldVersion == 1) {
        await db
            .execute('ALTER TABLE $t_favorite ADD COLUMN createTime integer');
      }
    });
  }

  closeDB() async {
    await db?.close();
  }

  /// 在数据库onCreate的时候，创建表。
  /// 注意：onUpgrade中添加的字段要在这儿添加，不然第一次安装就没有那个字段了。
  _createTableFavorite() {
    db.execute('''create table $t_favorite ( 
          id integer primary key, 
          name text not null,
          artist text,
          cover text,
          url text,
          createTime integer)
    ''');
  }

  Future<int> addFavorite(Map song) async {
    var fav = {
      'id': song['id'],
      'name': song['name'],
      'artist': SongUtil.getArtistNames(song),
      'cover': SongUtil.getSongImage(song, size: 0),
      'url': SongUtil.getSongUrl(song),
      // 查看sqflite文档，发现不支持DateTime字段，用int来存储。
      'createTime': DateTime.now().millisecondsSinceEpoch,
    };

    db = await getDB();
    return await db.insert(t_favorite, fav);
  }

  Future<int> updateFavorite(Map song) async {
    var fav = {
      'cover': song['imageUrl'],
    };

    db = await getDB();
    return await db.update(t_favorite, fav, where: 'id = ${song['id']}');
  }

  Future<List<Map<String, dynamic>>> getFavoriteList() async {
    db = await getDB();
    List list = await db.query(t_favorite, orderBy: 'createTime desc');
    List songs = list
        .map((fav) => {
              'id': fav['id'],
              'name': fav['name'],
              'artistNames': fav['artist'],
              'imageUrl': fav['cover']
            })
        .toList();

    return songs;
  }

  Future<Map<String, dynamic>> getFavoriteById(var id) async {
    db = await getDB();
    List list = await db.query(t_favorite, where: 'id = ?', whereArgs: [id]);
    return list.length > 0 ? list[0] : null;
  }

  Future<int> deleteFavorite(var id) async {
    db = await getDB();
    int re = await db.delete(t_favorite, where: 'id = ?', whereArgs: [id]);
    if (re <= 0) {
      throw Exception('删除失败');
    } else {
      return re;
    }
  }
}
