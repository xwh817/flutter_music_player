import 'package:flutter_music_player/model/song_util.dart';
import 'package:sqflite/sqflite.dart';

class MusicDB {
  static const db_version = 1;
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
  Future<Database> getDB() async{
    if (db == null) {
      db = await initDB();
    }
    return db;
  }


  Future<Database> initDB() async {
    print('initDB');
    return await openDatabase(db_file, 
      version: db_version,
      onCreate: (Database db, int version) async {
        // 初始化，创建表
        await db.execute('''create table $t_favorite ( 
          id integer primary key, 
          name text not null,
          artist text,
          cover text,
          url text)''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async{
        // 数据库升级策略
      }
    );
  }

  closeDB() async{
    await db?.close();
  }


  Future<int> addFavorite(Map song) async {
    var fav = {
      'id':song['id'],
      'name':song['name'],
      'artist':SongUtil.getArtistNames(song),
      'cover': SongUtil.getSongImage(song, size: 0),
      'url': SongUtil.getSongUrl(song)
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
    List list = await db.query(t_favorite);
    List songs = list.map((fav) => {
      'id': fav['id'],
      'name': fav['name'],
      'artistNames': fav['artist'],
      'imageUrl': fav['cover']
    }).toList();

    return songs;
  }

  Future<Map<String, dynamic>> getFavoriteById(var id) async {
    db = await getDB();
    List list = await db.query(t_favorite, where: 'id = ?', whereArgs: [id]);
    return list.length > 0 ? list[0] : null;
  }

  Future<int> deleteFavorite(var id) async{
    db = await getDB();
    int re = await db.delete(t_favorite, where: 'id = ?', whereArgs: [id]);
    if (re<=0) {
      throw Exception('删除失败');
    } else {
      return re;
    }
  }
}
