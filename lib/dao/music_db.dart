import 'package:flutter_music_player/model/song_util.dart';
import 'package:sqflite/sqflite.dart';

class MusicDB {
  final db_file = 'music.db';
  final t_favorite = 't_favorite';

  Database db;

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
  MusicDB._(){
    initDB();
  }


  Future initDB() async {
    db = await openDatabase(db_file, 
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''create table $t_favorite ( 
          id integer primary key autoincrement, 
          name text not null,
          artist text,
          cover text,
          url text)''');
      }
    );
  }

  closeDB() async{
    await db.close();
  }

  Future<int> addFavorite(Map song) async {
    var fav = {
      'id':song['id'],
      'name':song['name'],
      'artist':SongUtil.getArtistNames(song),
      'cover': SongUtil.getSongImage(song),
      'url': SongUtil.getSongUrl(song)
    };

    return await db.insert(t_favorite, fav);
  }

  Future<List<Map<String, dynamic>>> getFavoriteList() async {
    return db.query(t_favorite);
  }

  Future<Map<String, dynamic>> getFavoriteById(var id) async {
    List list = await db.query(t_favorite, where: 'id = ?', whereArgs: [id]);
    return list.length > 0 ? list[0] : null;
  }

  Future<int> deleteFavorite(var id) {
    return db.delete(t_favorite, where: 'id = ?', whereArgs: [id]);
  }
}
