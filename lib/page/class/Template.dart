
class Template {
  final String id;
  final String tags;
  final String link;
  final String hash;
  final bool isDaily;
  final int pathNum;
  final String jigsawId;
  final int jigsawNum;
  final int openDate;
  final bool isSpecial;
  String outPath = '';

  get url {
    return "https://d18z1pzpcvd03w.cloudfront.net/$id.png";
  }

  get isNew {
    var time = DateTime.fromMillisecondsSinceEpoch(openDate * 1000);
    var now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }

  Template(this.id, this.tags, this.link, this.hash, this.isDaily, this.pathNum,
      this.jigsawId, this.jigsawNum, this.openDate, this.isSpecial);

  Template.fromNotwork(Map<String, dynamic> json)
      : id = json['id'],
        tags = json['tags'].map((tag) => tag.toString()).toList().join(','),
        link = json['link'] ?? '',
        hash = json['hash'],
        isDaily = json['is_daily'],
        pathNum = json['path_num'],
        jigsawId = json['jigsaw_id'] ?? '',
        jigsawNum = json['jigsaw_num'],
        openDate = json['open_at'] ?? 0,
        isSpecial = json['tear_film'] ?? false;

  Template.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tags = json['tags'],
        link = json['link'],
        hash = json['hash'],
        isDaily = json['isDaily'] == 0 ? false : true,
        pathNum = json['pathNum'],
        jigsawId = json['jigsawId'],
        jigsawNum = json['jigsawNum'],
        openDate = json['openDate'] ?? 0,
        isSpecial = json['isSpecial'] == 0 ? false : true;

  Map<String, dynamic> toJson() => {
        'id': id,
        'hash': hash,
        'tags': tags,
        'link': link,
        'isDaily': isDaily ? 1 : 0,
        'pathNum': pathNum,
        'jigsawId': jigsawId,
        'jigsawNum': jigsawNum,
        'openDate': openDate,
        'isSpecial': isSpecial ? 1 : 0
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'hash': hash,
        'tags': tags,
        'link': link,
        'isDaily': isDaily,
        'pathNum': pathNum,
        'jigsawId': jigsawId,
        'jigsawNum': jigsawNum,
        'openDate': openDate,
        'isSpecial': isSpecial
      };
}


