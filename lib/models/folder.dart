import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/utils/db_utils.dart';
import 'package:sqflite/sqflite.dart';

const String folderTable = "md_folder";

const String _id = "id";
const String _name = "name";
const String _superID = "super_id";
const String _createdAt = "created_at";
const String _updatedAt = "updated_at";

const int folderType = 1;
const int articleType = 2;

class Folder {
  int? id;

  // 文件夹名称
  String? name;

  // 上级ID
  String? superID;

  DateTime? createdAt;
  DateTime? updatedAt;

  Folder({this.id, this.name, this.superID, this.createdAt, this.updatedAt});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      _name: name,
      _superID: superID,
    };
    return map;
  }

  Folder.fromMap(Map<dynamic, dynamic>? map) {
    id = map?[_id];
    name = map?[_name];
    superID = map?[_superID];
    createdAt = map?[_createdAt];
    updatedAt = map?[_updatedAt];
  }
}

class LevelRoot {
  int? id;

  // 文件名称
  String? name;

  // 上级ID
  int? superID;

  // 文件类型：1文件夹, 2文件
  int? type;

  String? content;

  DateTime? createdAt;
  DateTime? updatedAt;

  static String levelRootID = "id";
  static String levelRootName = "name";
  static String levelRootTitle = "title";
  static String levelRootSuperID = "super_id";
  static String levelRootType = "type";
  static String levelRootContent = "content";
  static String levelRootCreatedAt = "created_at";
  static String levelRootUpdatedAt = "updated_at";

  LevelRoot({this.id, this.name, this.superID, this.type, this.content, this.createdAt, this.updatedAt});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      levelRootID: id,
      levelRootName: name,
      levelRootSuperID: superID,
      levelRootType: type,
    };
    return map;
  }

  LevelRoot.fromMap(Map<dynamic, dynamic> map) {
    id = map[levelRootID];
    name = map[levelRootName] ?? map[levelRootTitle];
    superID = map[levelRootSuperID];
    type = map[levelRootType];
    content = map[levelRootContent];
    createdAt = DateTime.fromMillisecondsSinceEpoch(map[levelRootCreatedAt]);
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map[levelRootUpdatedAt]);
  }
}

class FolderProvider {
  static const String folderTable = 'md_folder';
  String createSql = """
    CREATE TABLE 
      $folderTable (
        $_id INTEGER PRIMARY KEY, 
        $_name VARCHAR(50) NOT NULL, 
        $_superID INTEGER DEFAULT 0,
        $_createdAt DATETIME NOT NULL,
        $_updatedAt DATETIME NOT NULL
      )
  """;

  Future insert(Folder folder) async {
    var _database = await DBProvider.db();
    var now = DateTime.now();
    var insertMap = folder.toMap();
    insertMap[_createdAt] = now;
    insertMap[_updatedAt] = now;
    return await _database.insert(folderTable, insertMap);
  }

  Future inserts(List<Folder> folders) async {
    var _database = await DBProvider.db();
    Batch? batch = _database.batch();
    for (var element in folders) {
      var now = DateTime.now();
      var insertMap = element.toMap();
      insertMap[_createdAt] = now;
      insertMap[_updatedAt] = now;
      batch.insert(folderTable, insertMap);
      print('${DateTime.now()}--${insertMap}');
    }
    return await batch.commit();
  }

  Future<Folder> query(int id) async {
    var _database = await DBProvider.db();
    List<Map>? maps = await _database.query(
      folderTable,
      columns: [_id, _name, _superID, _createdAt, _updatedAt],
      where: '$_id=?',
      whereArgs: [id],
      limit: 1,
    );
    return Folder.fromMap(maps.first);
  }

  Future<List<LevelRoot>> queryRoot(int id, {int limit = 10, offset = 0}) async {
    var _database = await DBProvider.db();
    List<LevelRoot> folderLevelRoots = [];
    List<Map>? folderMaps = await _database.query(
      folderTable,
      columns: [_id, _name, _superID, _createdAt, _updatedAt],
      where: '$_superID=?',
      whereArgs: [id],
      limit: limit,
      offset: offset
    );
    folderMaps.forEach((element) {
      element[LevelRoot.levelRootType] = folderType;
      element[LevelRoot.levelRootContent] = "";
      folderLevelRoots.add(LevelRoot.fromMap(element));
    });

    List<LevelRoot>? articleLevelRoots =
        await ArticleProvider().queryLevelRootWithSuperFolderID(id, limit: limit, offset: offset);
    if (articleLevelRoots.isNotEmpty){
      folderLevelRoots.addAll(articleLevelRoots);
    }
    return folderLevelRoots;
  }

  Future<List<Folder>> queryAll() async {
    var _database = await DBProvider.db();
    List<Map>? maps = await _database.query(folderTable);
    List<Folder> list = [];
    maps.forEach((element) {
      list.add(Folder.fromMap(element));
    });
    return list;
  }

  Future delete(int id) async {
    var _database = await DBProvider.db();
    return await _database.delete(
      folderTable,
      where: '$_id=?',
      whereArgs: [id],
    );
  }

  Future update(Folder folder) async {
    var _database = await DBProvider.db();
    var now = DateTime.now();
    var updateMap = folder.toMap();
    updateMap[_updatedAt] = now;
    return await _database.update(
      folderTable,
      updateMap,
    );
  }

  Future close() async {
    var _database = await DBProvider.db();
    return await _database.close();
  }

  Future drop() async {
    String path = await getDatabasesPath();
    path = '$path/edit_md.db';
    return await deleteDatabase(path);
  }

  Future clear() async {
    var _database = await DBProvider.db();
    await _database.delete(folderTable);
  }
}
