import 'dart:io';
import 'package:flutter_md_edit/models/article.dart';
import 'package:flutter_md_edit/models/folder.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Future<Database> db() async {
    return openDatabase('edit_md.db', version: 1,
        onCreate: (Database database, int version) async {
      await _onCreate(database, 1);
    }, onUpgrade: (Database database, int oldVersion, int newVersion) async {
      await _onUpgrade(database, 1, 2);
    });
  }

  ///
  /// 创建Table
  ///
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(ArticleProvider().createSql);
    await db.execute(FolderProvider().createSql);
  }

  ///
  /// 版本升级（数据表有变更时）
  ///
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();
    if (oldVersion == 1) {
      batch.execute('''
      alter table $articleTable 
        add $articleSha VARCHAR(255),
        add $articleIsDraft SMALLINT(1) DEFAULT 0,
        add $articleDeactivatedAt INTEGER
      '''
      );
      batch.execute('''
      alter table $folderTable 
        add $folderDeactivatedAt INTEGER
      '''
      );
    } else if (oldVersion == 2) {
      // batch.execute('alter table ta_person add water text');
    } else if (oldVersion == 3) {}
    oldVersion++;
    //升级后版本还低于当前版本，继续递归升级
    if (oldVersion < newVersion) {
      _onUpgrade(db, oldVersion, newVersion);
    }
    await batch.commit();
  }

  ///
  /// 版本降级
  ///
  Future _onDowngrade(Database db, int oldVersion, int newVersion) async {
    Batch batch = db.batch();

    await batch.commit();
  }

  Future<bool> isTableExists(String table) async {
    final db = await DBProvider.db();
    String sql =
        "select * from Sqlite_master where type='table' and name= '$table'";
    var result = await db.rawQuery(sql);
    return result.isNotEmpty;
  }
}

// class DBProvider {
//   static final DBClient _singleton = DBClient._internal();
//
//   factory DBClient() {
//     return _singleton;
//   }
//
//   DBProvider._internal();
//
//   static late Database _db;
//
//   Future<Database> get db async {
//     if (_db != null) {
//       return _db;
//     }
//     _db = await _initDB();
//     return _db;
//   }
//
//   Future<Database> _initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'edit_md.db');
//     final db = await openDatabase(path,
//         version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
//     return db;
//   }
//
//   ///
//   /// 创建Table
//   ///
//   Future _onCreate(Database db, int version) async {
//     db.execute(ArticleProvider().createSql);
//     db.execute(FolderProvider().createSql);
//   }
//
//   ///
//   /// 版本升级（数据表有变更时）
//   ///
//   Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     Batch batch = db.batch();
//     if (oldVersion == 1) {
//       // batch.execute('alter table ta_person add fire text');
//     } else if (oldVersion == 2) {
//       // batch.execute('alter table ta_person add water text');
//     } else if (oldVersion == 3) {}
//     oldVersion++;
//     //升级后版本还低于当前版本，继续递归升级
//     if (oldVersion < newVersion) {
//       _onUpgrade(db, oldVersion, newVersion);
//     }
//     await batch.commit();
//   }
//
//   ///
//   /// 版本降级
//   ///
//   Future _onDowngrade (Database db, int oldVersion, int newVersion) async {
//     Batch batch = db.batch();
//
//     await batch.commit();
//   }
//
//   Future<bool> isTableExists(String table) async {
//     String sql =
//         "select * from Sqlite_master where type='table' and name= '$table'";
//     var result = await _db.rawQuery(sql);
//     return result.isNotEmpty;
//   }
//
// }
