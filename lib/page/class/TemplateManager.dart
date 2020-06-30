import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutterapp/page/class/Template.dart';
import 'package:flutterapp/page/db/template_db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const CategoryTypes = [
  'new',
  'basic',
  'jigsaw',
  'people',
  'wallpaper',
  'glitter',
  'bonus',
  'holidays',
  'animal',
  'scenery',
  'messages',
  'fashion',
  'floral',
  'heart',
  'fantasy',
  'mandala',
  'cartoon',
  'folk',
  'nature',
  'patterns',
  'food',
  'others',
];

class TemplateManager {
  List pictures;
  int version;
  List<String> categoryTypes = [
    'basic',
    'bonus',
    'people',
    'jigsaw',
    'holidays',
    'animal',
    'scenery',
    'messages',
    'fashion',
    'floral',
    'heart',
    'fantasy',
    'mandala',
    'cartoon',
    'folk',
    'nature',
    'patterns',
    'food',
    'others',
    'glitter',
    'wallpaper',
  ];

  static final Map<String, String> categoryNames = {
    'new': 'New',
    'basic': 'Featured',
    'jigsaw': 'Jigsaw',
    'people': 'People',
    'wallpaper': 'Wallpaper',
    'glitter': 'Glitter',
    'bonus': 'Bonus',
    'holidays': 'Holidays',
    'animal': 'Animal',
    'scenery': 'Scenery',
    'messages': 'Messages',
    'fashion': 'Fashion',
    'floral': 'Floral',
    'heart': 'Heart',
    'fantasy': 'Fantasy',
    'mandala': 'Mandala',
    'cartoon': 'Cartoon',
    'folk': 'Folk',
    'nature': 'Nature',
    'patterns': 'Patterns',
    'food': 'Food',
    'others': 'Others',
  };

  List<Template> _library;

  Map<String, List<Template>> _categories;

  List<Template> daily = new List();
  List<Template> dailyHeaders = new List();

  TemplateManager();

  TemplateManager.fromJson(Map<String, dynamic> json)
      : pictures = json['pictures'],
        version = json['version'];

  DateTime get today {
    DateTime today = DateTime.now();
    return DateTime(today.year, today.month, today.day, 23, 59, 59);
  }

  Future syncRemoteLibrary() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var eTag = preferences.get('eTag') ?? '';
    var url =
        "https://d18z1pzpcvd03w.cloudfront.net/manifest_2.json?${DateTime.now().millisecondsSinceEpoch}";
    var httpClient = new HttpClient();
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      request.headers.add('If-None-Match', eTag);
      var response = await request.close();
      print(response.statusCode.toString());
      if (response.statusCode == HttpStatus.ok) {
        preferences.setString('eTag', response.headers.value('etag'));
        var json = await response.transform(utf8.decoder).join();
        var p = jsonDecode(json);
        pictures = p['pictures'];
      }
    } catch (e) {}

    TemplateProvider provider = new TemplateProvider();
    Database db = await provider.getDataBase();
    if (pictures != null) {
      await db.transaction((txn) async {
        pictures.forEach((element) {
          Template template = Template.fromNotwork(element);
          provider.insert(txn, template);
        });
      });
    }
    List<Template> data = await provider.getAllTemplatesByTime(db, today);
    _library = data;
  }

  Map<String, List<Template>> getGallery() {
    if (_categories == null) {
      Map<String, List<Template>> categoryMap = new Map();
      _library.forEach((template) {
        if (template.openDate * 1000 <= today.millisecondsSinceEpoch) {
          if (template.isNew && template.isDaily) return;
          template.tags.split(',').forEach((tag) {
            if (categoryTypes.contains(tag)) {
              if (!categoryMap.containsKey(tag)) {
                categoryMap[tag] = new List();
              }
              categoryMap[tag].add(template);
            } else {
              if (!categoryMap.containsKey('new')) {
                categoryMap['new'] = new List();
              }
              categoryMap['new'].add(template);
            }
          });
        }
      });
      _categories = new Map();
      CategoryTypes.forEach((element) {
        if (categoryMap[element] != null) {
          _categories[element] = categoryMap[element].reversed.toList();
        }
      });
    }
    return _categories;
  }

  Future<List<Template>> getDaily() async {
    if (daily.length <= 0) {
      DateTime time = today.add(Duration(days: 1));
      TemplateProvider provider = new TemplateProvider();
      Database db = await provider.getDataBase();
      List<Template> data = await provider.getAllTemplates(db);
      data.forEach((template) {
        if (template.isDaily) {
          if (template.openDate * 1000 <
              today.subtract(Duration(days: 1)).millisecondsSinceEpoch) {
            daily.add(template);
          } else if (template.openDate * 1000 <= time.millisecondsSinceEpoch)
            dailyHeaders.add(template);
        }
      });
    }
    return daily.reversed.toList();
  }

  Future<Template> getTemplateById(String id) async {
    TemplateProvider provider = new TemplateProvider();
    Database db = await provider.getDataBase();
    return await provider.getTemplatesById(db, id);
  }

  Future download(String id, String hash) async {
    var url = "https://d18z1pzpcvd03w.cloudfront.net/$id.$hash.zip";
    String path = await getDownloadPath();

    var fileJson = File('$path/$id.json');
    if (fileJson.existsSync()) return;

    Response response = await Dio().download(url, '$path/$id.zip');

    if (response.statusCode == HttpStatus.ok) {
      var file = File('$path/$id.zip');
      var bytes = file.readAsBytesSync();
      var archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final name = file.name;
        File('$path/$name')
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      }
      await file.delete();
    }
  }

  Future<String> getDownloadPath() async {
    Directory directory = await getApplicationDocumentsDirectory();

    Directory download = Directory('${directory.path}/download_tmp');
    if (download.existsSync()) {
      return download.path;
    }
    download.createSync();
    return download.path;
  }
}
