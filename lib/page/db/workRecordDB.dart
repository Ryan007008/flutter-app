import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/page/class/workRecord.dart';
import 'package:flutterapp/page/db/sqlManager.dart';
import 'package:sqflite/sqflite.dart';

class WorkRecordProvider extends BaseDbProvider {
  final String name = 'WorkRecord';
  final String wordId = 'wordId';
  final String templateId = 'templateId';
  final String createDate = 'createDate';
  final String updateDate = 'updateDate';
  final String finishDate = 'finishDate';
  final String exportRawFile = 'exportRawFile';
  final String exportFinalFile = 'exportFinalFile';
  final String exportJigsawFinalFile = 'exportJigsawFinalFile';
  final String finishMark = 'finishMark';

  @override
  createTableString() {
    return "CREATE TABLE $name($wordId TEXT PRIMARY KEY, $templateId TEXT, $createDate TEXT, $updateDate TEXT,"
        "$finishDate TEXT, $exportRawFile TEXT, $exportFinalFile TEXT, $exportJigsawFinalFile TEXT, $finishMark INTEGER)";
  }

  @override
  tableName() {
    return name;
  }

  ///获取事件数据
  Future<WorkRecord> getWorkRecordById(String templateId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await  db.query(name,
        where: "templateId == ?", whereArgs: [templateId]);
    if (maps.length > 0) {
      return WorkRecord.fromJson(maps[0]);
    }
    return null;
  }

  ///插入到数据库
  void insert(WorkRecord model) async {
    Database db = await getDataBase();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.insert(name, model.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }

  ///更新到数据库
  void update(WorkRecord model) async {
    Database db = await getDataBase();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.update(name, model.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }
}
