class WorkRecord {
  final String wordId;
  final String templateId;
  final String createDate;
  String updateDate;
  String finishDate;
  String exportRawFile;
  String exportFinalFile;
  String exportJigsawFinalFile;
  int finishMark;

  WorkRecord(this.wordId, this.templateId, this.createDate);

  WorkRecord.fromJson(Map<String, dynamic> json)
      : wordId = json['wordId'],
        templateId = json['templateId'],
        createDate = json['createDate'],
        updateDate = json['updateDate'],
        finishDate = json['finishDate'],
        exportRawFile = json['exportRawFile'],
        exportFinalFile = json['exportFinalFile'],
        exportJigsawFinalFile = json['exportJigsawFinalFile'],
        finishMark = json['finishMark'];

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'templateId': templateId,
        'createDate': createDate,
        'updateDate': updateDate ?? '',
        'finishDate': finishDate ?? '',
        'exportRawFile': exportRawFile ?? '',
        'exportFinalFile': exportFinalFile ?? '',
        'exportJigsawFinalFile': exportJigsawFinalFile ?? '',
        'finishMark': finishMark ?? 0
      };
}
