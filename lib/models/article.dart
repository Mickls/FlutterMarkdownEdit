import 'package:flutter_md_edit/models/folder.dart';
import 'package:flutter_md_edit/models/db_utils.dart';
import 'package:sqflite/sqflite.dart';

const String articleTable = 'md_article';

const String articleId = 'id';
const String articleTitle = 'title';
const String articleContent = 'content';
const String articleSuperFolderID = 'super_id';
const String articleSha = 'sha';
const String articleIsDraft = "is_draft";
const String articleCreatedAt = 'created_at';
const String articleUpdatedAt = 'updated_at';
const String articleDeactivatedAt = 'deactivated_at';

class Article {
  int? id;
  String? title;
  String? content;
  int? superFolderID;
  String? sha;
  int? isDraft;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deactivatedAt;

  Article({
    this.id,
    required this.title,
    required this.content,
    this.superFolderID,
    this.sha,
    this.isDraft,
    this.createdAt,
    this.updatedAt,
    this.deactivatedAt,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      articleId: id,
      articleTitle: title,
      articleContent: content,
      articleSuperFolderID: superFolderID,
      articleSha: sha,
      articleIsDraft: isDraft,
      articleCreatedAt: createdAt,
      articleUpdatedAt: updatedAt,
      articleDeactivatedAt: deactivatedAt,
    };
    return map;
  }

  Article.fromMap(Map<dynamic, dynamic>? map) {
    id = map?[articleId];
    title = map?[articleTitle];
    content = map?[articleContent];
    superFolderID = map?[articleSuperFolderID];
    sha = map?[articleSha];
    isDraft = map?[articleIsDraft];
    createdAt = DateTime.fromMillisecondsSinceEpoch(map?[articleCreatedAt]);
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map?[articleUpdatedAt]);
    deactivatedAt =
        DateTime.fromMillisecondsSinceEpoch(map?[articleDeactivatedAt] ?? 0);
  }
}

class ArticleProvider {
  // late Database _database;
  // static const String articleTable = 'md_article';
  String createSql = '''
  CREATE TABLE 
    $articleTable (
      $articleId INTEGER PRIMARY KEY,
      $articleTitle VARCHAR(50) NOT NULL,
      $articleContent TEXT NOT NULL,
      $articleSuperFolderID INTEGER DEFAULT 0,
      $articleSha VARCHAR(255),
      $articleIsDraft SMALLINT(1) DEFAULT 0,
      $articleCreatedAt INTEGER NOT NULL,
      $articleUpdatedAt INTEGER NOT NULL,
      $articleDeactivatedAt INTEGER
    )
  ''';

  Future<int> insert(Article article) async {
    final db = await DBProvider.db();
    var insertMap = article.toMap();
    insertMap.removeWhere((key, value) => value == null);
    var now = DateTime.now().millisecondsSinceEpoch;
    insertMap[articleCreatedAt] = now;
    insertMap[articleUpdatedAt] = now;
    return await db.insert(articleTable, insertMap);
  }

  Future inserts(List<Article> articles) async {
    final db = await DBProvider.db();
    Batch? batch = db.batch();
    for (var element in articles) {
      var insertMap = element.toMap();
      insertMap.removeWhere((key, value) => value == null);
      var now = DateTime.now().millisecondsSinceEpoch;
      insertMap[articleCreatedAt] = now;
      insertMap[articleUpdatedAt] = now;
      batch.insert(articleTable, insertMap);
      print('${DateTime.now()}--${insertMap}');
    }
    return await batch.commit();
  }

  Future<Article> query(int id) async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(
      articleTable,
      columns: [
        articleId,
        articleTitle,
        articleContent,
        articleSuperFolderID,
        articleIsDraft,
        articleCreatedAt,
        articleUpdatedAt,
      ],
      where: '$articleId=? AND $articleDeactivatedAt is NULL',
      whereArgs: [id],
      limit: 1,
    );
    return Article.fromMap(maps.first);
  }

  Future<LevelRoot> queryLevelRootWithArticleID(int id) async {
    final db = await DBProvider.db();
    List<Map>? maps = await db.query(
      articleTable,
      columns: [
        articleId,
        articleTitle,
        articleContent,
        articleSuperFolderID,
        articleCreatedAt,
        articleUpdatedAt,
      ],
      where: '$articleId=?',
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
          articleId,
          articleTitle,
          articleContent,
          articleSuperFolderID,
          articleCreatedAt,
          articleUpdatedAt,
        ],
        where: '$articleSuperFolderID=?',
        whereArgs: [id],
        offset: offset,
        limit: limit,
        orderBy: '-$articleCreatedAt');
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
      where: '$articleId=?',
      whereArgs: [id],
    );
  }

  Future update(Article article, int id) async {
    final db = await DBProvider.db();
    var now = DateTime.now().millisecondsSinceEpoch;
    var updateMap = article.toMap();
    updateMap.removeWhere((key, value) => value == null);
    updateMap[articleUpdatedAt] = now;
    return await db.update(
      articleTable,
      updateMap,
      where: '$articleId=?',
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
