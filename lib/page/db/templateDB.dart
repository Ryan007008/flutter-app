import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/page/class/workRecord.dart';
import 'package:flutterapp/page/db/sqlManager.dart';
import 'package:flutterapp/page/db/workRecordDB.dart';
import 'package:sqflite/sqflite.dart';

class TemplateProvider extends BaseDbProvider {
  final String name = 'TemplateInfo';
  final String id = "id";
  final String tags = "tags";
  final String link = "link";
  final String hash = "hash";
  final String isDaily = "isDaily";
  final String pathNum = "pathNum";
  final String jigsawId = "jigsawId";
  final String jigsawNum = "jigsawNum";
  final String openDate = "openDate";
  final String isSpecial = "isSpecial";
  final String downloaded = "downloaded";

  @override
  createTableString() {
    return "CREATE TABLE $name(id TEXT PRIMARY KEY, $tags TEXT, $link TEXT, $hash TEXT, $isDaily INTEGER,"
        "$pathNum INTEGER, $jigsawId TEXT, $jigsawNum INTEGER, $openDate INTEGER, $isSpecial INTEGER, $downloaded INTEGER)";
  }

  @override
  tableName() {
    return name;
  }

  ///获取事件数据
  Future<List<Template>> getAllTemplatesByTime(DateTime dateTime) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(name,
        where: "openDate <= ?", whereArgs: [dateTime.millisecondsSinceEpoch]);
    if (maps.length > 0) {
      return maps.map((e) => Template.fromJson(e)).toList();
    }
    return null;
  }

  ///获取事件数据
  Future<Template> getTemplatesById(String id) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps =
        await db.query(name, where: "id == ?", whereArgs: [id]);
    if (maps.length > 0) {
      return Template.fromJson(maps[0]);
    }
    return null;
  }

  ///获取事件数据
  Future<List<Template>> getAllTemplates() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps;
    await db.transaction((txn) async {
      maps = await txn.query(name);
    });
    if (maps.length > 0) {
      return maps.map((e) => Template.fromJson(e)).toList();
    }
    return null;
  }

  ///插入到数据库
  Future insert(Transaction db, Template model) async {
    var batch = db.batch();
    batch.insert(name, model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await batch.commit(noResult: true);
  }

  ///更新到数据库
  Future update(String id, Map<String, dynamic> values) async {
    Database db = await getDataBase();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.update(name, values, where: 'id=?', whereArgs: [id],
          conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }
}
