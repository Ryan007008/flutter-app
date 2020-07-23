import 'dart:collection';

import 'package:flutterapp/page/class/stepRecord.dart';
import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/page/class/workRecord.dart';
import 'package:flutterapp/page/db/steoRecordDB.dart';
import 'package:flutterapp/page/db/workRecordDB.dart';

class WorkManagerInstance {
  Template template;
  WorkRecord workRecord;
  WorkRecordProvider provider;
  StepRecordProvider stepRecordProvider;
  List<StepRecord> stepRecords;
  Map<String, Set<String>> fillColors = LinkedHashMap();

  factory WorkManagerInstance() => _getInstance();

  static WorkManagerInstance _instance;

  WorkManagerInstance._() {
    provider = WorkRecordProvider();
    stepRecordProvider = StepRecordProvider();
  }

  static WorkManagerInstance _getInstance() {
    if (_instance == null) {
      _instance = WorkManagerInstance._();
    }
    return _instance;
  }

  getConfig() async {
    var steps = await getStepRecords();
    steps.forEach((step) {
      if (!fillColors.containsKey(step.colorVal)) {
        fillColors[step.colorVal] = Set.from([]);
      }
      fillColors[step.colorVal].add(step.pathId);
    });
  }

  WorkRecord createNewWork(Template tmp) {
    template = tmp;
    var now = DateTime.now().millisecondsSinceEpoch;
    var workId = '${tmp.id}-$now';
    workRecord = WorkRecord(workId, tmp.id, now.toString());
    provider.insert(workRecord);
    return workRecord;
  }

  void continueWork(Template tmp) {
    template = tmp;
    workRecord = tmp.record;
  }

  setFillColor(String colorVal, List<String> pathId) {
    print('aaaa');
    if (!fillColors.containsKey(colorVal)) {
      fillColors[colorVal] = Set<String>.from([]);
    }
    fillColors[colorVal].addAll(pathId);
  }

  void saveSteps() {
    fillColors.forEach((key, value) {
      if (value.length >= 0) {
        value.forEach((id) {
          StepRecord record = StepRecord(
              template.record.wordId, '${template.record.wordId}-$id', key, id);
          stepRecordProvider.insert(record);
        });
      }
    });
  }

  Future<List<StepRecord>> getStepRecords() async {
    return await stepRecordProvider.getStepRecords(workRecord.wordId);
  }
}
