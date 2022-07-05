import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/models/db_utils.dart';
import 'package:sqflite/sqflite.dart';

const String folderTable = "md_folder";

const String folderId = "id";
const String folderName = "name";
const String folderSuperID = "super_id";
const String folderCreatedAt = "created_at";
const String folderUpdatedAt = "updated_at";
const String folderDeactivatedAt = 'deactivated_at';

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
  DateTime? deactivatedAt;

  Folder({
    this.id,
    this.name,
    this.superID,
    this.createdAt,
    this.updatedAt,
    this.deactivatedAt,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      folderName: name,
      folderSuperID: superID,
    };
    return map;
  }

  Folder.fromMap(Map<dynamic, dynamic>? map) {
    id = map?[folderId];
    name = map?[folderName];
    superID = map?[folderSuperID];
    createdAt = map?[folderCreatedAt];
    updatedAt = map?[folderUpdatedAt];
    deactivatedAt = map?[folderDeactivatedAt];
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

  LevelRoot(
      {this.id,
      this.name,
      this.superID,
      this.type,
      this.content,
      this.createdAt,
      this.updatedAt});

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
        $folderId INTEGER PRIMARY KEY, 
        $folderName VARCHAR(50) NOT NULL, 
        $folderSuperID INTEGER DEFAULT 0,
        $folderCreatedAt INTEGER NOT NULL,
        $folderUpdatedAt INTEGER NOT NULL,
        $folderDeactivatedAt INTEGER NOT NULL
      )
  """;

  Future insert(Folder folder) async {
    var _database = await DBProvider.db();
    var now = DateTime.now();
    var insertMap = folder.toMap();
    insertMap[folderCreatedAt] = now;
    insertMap[folderUpdatedAt] = now;
    return await _database.insert(folderTable, insertMap);
  }

  Future inserts(List<Folder> folders) async {
    var _database = await DBProvider.db();
    Batch? batch = _database.batch();
    for (var element in folders) {
      var now = DateTime.now();
      var insertMap = element.toMap();
      insertMap[folderCreatedAt] = now;
      insertMap[folderUpdatedAt] = now;
      batch.insert(folderTable, insertMap);
      print('${DateTime.now()}--${insertMap}');
    }
    return await batch.commit();
  }

  Future<Folder> query(int id) async {
    var _database = await DBProvider.db();
    List<Map>? maps = await _database.query(
      folderTable,
      columns: [
        folderId,
        folderName,
        folderSuperID,
        folderCreatedAt,
        folderUpdatedAt
      ],
      where: '$folderId=?',
      whereArgs: [id],
      limit: 1,
    );
    return Folder.fromMap(maps.first);
  }

  Future<List<LevelRoot>> queryLevelRootWithID(int id,
      {int limit = 10, offset = 0}) async {
    var _database = await DBProvider.db();
    List<LevelRoot> folderLevelRoots = [];
    List<Map>? folderMaps = await _database.query(
      folderTable,
      columns: [
        folderId,
        folderName,
        folderSuperID,
        folderCreatedAt,
        folderUpdatedAt
      ],
      where: '$folderSuperID=?',
      whereArgs: [id],
      limit: limit,
      offset: offset,
    );
    for (var element in folderMaps) {
      element[LevelRoot.levelRootType] = folderType;
      element[LevelRoot.levelRootContent] = "";
      folderLevelRoots.add(LevelRoot.fromMap(element));
    }

    List<LevelRoot>? articleLevelRoots = await ArticleProvider()
        .queryLevelRootWithSuperFolderID(id, limit: limit, offset: offset);
    if (articleLevelRoots.isNotEmpty) {
      folderLevelRoots.addAll(articleLevelRoots);
    }
    return folderLevelRoots;
  }

  Future<List<LevelRoot>> queryLevelRootWithKey(String key) async {
    var _database = await DBProvider.db();
    List<LevelRoot> folderLevelRoots = [];
    List<Map>? folderMaps = await _database.query(
      folderTable,
      columns: [
        folderId,
        folderName,
        folderSuperID,
        folderCreatedAt,
        folderUpdatedAt
      ],
      where: '$folderName like ?',
      whereArgs: ['%$key%'],
    );
    for (var element in folderMaps) {
      element[LevelRoot.levelRootType] = folderType;
      element[LevelRoot.levelRootContent] = "";
      folderLevelRoots.add(LevelRoot.fromMap(element));
    }

    List<LevelRoot>? articleLevelRoots = await ArticleProvider()
        .queryLevelRootWithKey(key);
    if (articleLevelRoots.isNotEmpty) {
      folderLevelRoots.addAll(articleLevelRoots);
    }
    return folderLevelRoots;
  }

  Future<List<Folder>> queryAll() async {
    var _database = await DBProvider.db();
    List<Map>? maps = await _database.query(folderTable);
    List<Folder> list = [];
    for (var element in maps) {
      list.add(Folder.fromMap(element));
    }
    return list;
  }

  Future delete(int id) async {
    var _database = await DBProvider.db();
    return await _database.delete(
      folderTable,
      where: '$folderId=?',
      whereArgs: [id],
    );
  }

  Future update(Folder folder) async {
    var _database = await DBProvider.db();
    var now = DateTime.now();
    var updateMap = folder.toMap();
    updateMap[folderUpdatedAt] = now;
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
