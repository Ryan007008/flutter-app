import 'package:flutterapp/page/class/stepRecord.dart';
import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/page/class/workRecord.dart';
import 'package:flutterapp/page/db/sqlManager.dart';
import 'package:sqflite/sqflite.dart';

class StepRecordProvider extends BaseDbProvider {
  final String name = 'StepRecord';
  final String stepId = 'stepId';
  final String wordId = 'wordId';
  final String pathId = 'pathId';
  final String colorVal = 'colorVal';

  @override
  createTableString() {
    return "CREATE TABLE $name($stepId TEXT PRIMARY KEY, $wordId TEXT, $pathId TEXT, $colorVal TEXT)";
  }

  @override
  tableName() {
    return name;
  }

  ///获取事件数据
  Future<List<StepRecord>> getStepRecords(String wordId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await  db.query(name,
        where: "wordId == ?", whereArgs: [wordId]);
    if (maps.length > 0) {
      return maps.map((e) => StepRecord.fromJson(e)).toList();
    }
    return null;
  }

  ///插入到数据库
  void insert(StepRecord model) async {
    Database db = await getDataBase();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.insert(name, model.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }

  ///插入到数据库
  void delete(String workId) async {
    Database db = await getDataBase();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.delete(name, where: 'workId == ? ', whereArgs: [workId]);
      await batch.commit(noResult: true);
    });
  }
}
