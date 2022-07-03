import 'package:flutter_md_edit/models/folder.dart';
import 'package:flutter_md_edit/utils/db_utils.dart';
import 'package:sqflite/sqflite.dart';

// 表名
const String articleTable = 'md_article';

const String _id = 'id';
// 标题
const String _title = 'title';
// 内容
const String _content = 'content';
// 上级文件夹ID
const String _superFolderID = 'super_id';
const String _createdAt = "created_at";
const String _updatedAt = "updated_at";

class Article {
  int? id;
  String? title;
  String? content;
  int? superFolderID;
  DateTime? createdAt;
  DateTime? updatedAt;

  Article(
      {this.id,
      required this.title,
      required this.content,
      this.superFolderID,
      this.createdAt,
      this.updatedAt});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      _id: id,
      _title: title,
      _content: content,
      _superFolderID: superFolderID,
      _createdAt: createdAt,
      _updatedAt: updatedAt,
    };
    return map;
  }

  Article.fromMap(Map<dynamic, dynamic>? map) {
    id = map?[_id];
    title = map?[_title];
    content = map?[_content];
    superFolderID = map?[_superFolderID];
    createdAt = DateTime.fromMillisecondsSinceEpoch(map?[_createdAt]);
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map?[_updatedAt]);
  }
}

class ArticleProvider {
  // late Database _database;
  // static const String articleTable = 'md_article';
  String createSql = """
  CREATE TABLE 
    $articleTable (
      $_id INTEGER PRIMARY KEY,
      $_title VARCHAR(50) NOT NULL,
      $_content TEXT NOT NULL,
      $_superFolderID INTEGER DEFAULT 0,
      $_createdAt DATETIME NOT NULL,
      $_updatedAt DATETIME NOT NULL
    )
  """;

  // articleProvider() async {
  //   _database =  await DBProvider.db();
  // }

  Future insert(Article article) async {
    final db = await DBProvider.db();
    var insertMap = article.toMap();
    insertMap.removeWhere((key, value) => value == null);
    var now = DateTime.now().millisecondsSinceEpoch;
    insertMap[_createdAt] = now;
    insertMap[_updatedAt] = now;
    return await db.insert(articleTable, insertMap);
  }

  Future inserts(List<Article> articles) async {
    final db = await DBProvider.db();
    Batch? batch = db.batch();
    for (var element in articles) {
      var insertMap = element.toMap();
      insertMap.removeWhere((key, value) => value == null);
      var now = DateTime.now().millisecondsSinceEpoch;
      insertMap[_createdAt] = now;
      insertMap[_updatedAt] = now;
      batch.insert(articleTable, insertMap);
      print('${DateTime.now()}--${insertMap}');
    }
    return await batch.commit();
  }

  Future<Article> query(int id) async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(
      articleTable,
      columns: [_id, _title, _content, _superFolderID, _createdAt, _updatedAt],
      where: '$_id=?',
      whereArgs: [id],
      limit: 1,
    );
    return Article.fromMap(maps.first);
  }

  Future<LevelRoot> queryLevelRootWithArticleID(int id) async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(
      articleTable,
      columns: [_id, _title, _content, _superFolderID, _createdAt, _updatedAt],
      where: '$_id=?',
      whereArgs: [id],
      limit: 1,
    );
    final element = Map.from(maps.first);
    element[LevelRoot.levelRootType] = articleType;
    return LevelRoot.fromMap(element);
  }

  Future<List<LevelRoot>> queryLevelRootWithSuperFolderID(int id,
      {int offset = 0, limit = 10}) async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(articleTable,
        columns: [
          _id,
          _title,
          _content,
          _superFolderID,
          _createdAt,
          _updatedAt
        ],
        where: '$_superFolderID=?',
        whereArgs: [id],
        offset: offset,
        limit: limit,
        orderBy: '-$_createdAt');
    List<LevelRoot> list = [];
    maps.forEach((element) {
      var el = Map.from(element);
      el[LevelRoot.levelRootType] = articleType;
      list.add(LevelRoot.fromMap(el));
    });
    return list;
  }

  Future<List<Article>> queryAll() async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(articleTable);
    List<Article> list = [];
    maps.forEach((element) {
      list.add(Article.fromMap(element));
    });
    return list;
  }

  Future delete(int id) async {
    final db = await DBProvider.db();
    return await db.delete(
      articleTable,
      where: '$_id=?',
      whereArgs: [id],
    );
  }

  Future update(Article article, int id) async {
    final db = await DBProvider.db();
    var now = DateTime.now().millisecondsSinceEpoch;
    var updateMap = article.toMap();
    updateMap.removeWhere((key, value) => value == null);
    updateMap[_updatedAt] = now;
    return await db.update(
      articleTable,
      updateMap,
      where: '$_id=?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await DBProvider.db();
    return await db.close();
  }

  Future drop() async {
    String path = await getDatabasesPath();
    path = '$path/edit_md.db';
    return await deleteDatabase(path);
  }

  Future clear() async {
    final db = await DBProvider.db();
    await db.delete(articleTable);
  }
}
