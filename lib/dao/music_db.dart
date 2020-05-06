import 'package:flutter_music_player/dao/music_db_history.dart';
import 'package:flutter_music_player/dao/music_db_playlist.dart';
import 'package:sqflite/sqflite.dart';

import 'music_db_favorite.dart';

class MusicDB {
  static const db_version = 4;
  static const db_file = 'music.db';

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
      FavoriteDB().createTable(db);
      HistoryDB().createTable(db);
      PlayListDB().createTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // 数据库升级，修改表结构。
      if (oldVersion == 1) {
        oldVersion++;
        await db.execute(
            'ALTER TABLE ${FavoriteDB.table_name} ADD COLUMN createTime integer');
      }
      if (oldVersion == 2) {
        oldVersion++;
        HistoryDB().createTable(db);
      }
      if (oldVersion == 3) {
        oldVersion++;
        PlayListDB().createTable(db);
      }
    });
  }

  closeDB() async {
    await db?.close();
  }
}
