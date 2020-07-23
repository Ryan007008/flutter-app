class StepRecord {
  final String wordId;
  final String stepId;
  final String colorVal;
  final String pathId;

  StepRecord(this.wordId, this.stepId, this.colorVal, this.pathId);

  StepRecord.fromJson(Map<String, dynamic> json)
      : wordId = json['wordId'],
        stepId = json['stepId'],
        colorVal = json['colorVal'],
        pathId = json['pathId'];

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'stepId': stepId,
        'colorVal': colorVal,
        'pathId': pathId
      };
}
