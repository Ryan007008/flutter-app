import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

class SqlManager {
  static const _VERSION = 1;
  static const _NAME = 'coloringfun.db';
  static Database _database;

  static init() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _NAME);

    _database = await openDatabase(path,
        version: _VERSION, onCreate: (Database db, int version) async {});
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }

  ///判断表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }
}

abstract class BaseDbProvider {
  bool isTableExits = false;

  createTableString();

  tableName();

  ///创建表sql语句
  tableBaseString(String sql) {
    return sql;
  }

  Future<Database> getDataBase() async {
    return await open();
  }

  @mustCallSuper
  prepare(name, String createSql) async {
    isTableExits = await SqlManager.isTableExits(name);
    if (!isTableExits) {
      Database db = await SqlManager.getCurrentDatabase();
      return await db.execute(createSql);
    }
  }

  @mustCallSuper
  open() async {
    if (!isTableExits) {
      print('tableName(): ${tableName()}');
      await prepare(tableName(), createTableString());
    }
    return await SqlManager.getCurrentDatabase();
  }

}

