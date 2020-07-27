import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/page/test/customPaintRect.dart';
import 'package:flutterapp/page/test/edit.dart';
import 'package:path_provider/path_provider.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListState();
  }
}

class ListState extends State<ListPage> {
  List<Map<String, dynamic>> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = [
      {'title': '第 1 关', 'fileName': 'testData0', 'area': '5', 'id': 0},
      {'title': '第 2 关', 'fileName': 'testData1', 'area': '5', 'id': 1},
      {'title': '第 3 关', 'fileName': 'testData2', 'area': '5', 'id': 2},
      {'title': '第 4 关', 'fileName': 'testData3', 'area': '5', 'id': 3},
      {'title': '第 5 关', 'fileName': 'testData4', 'area': '9', 'id': 4},
      {'title': '第 6 关', 'fileName': 'testData5', 'area': '5', 'id': 5},
      {'title': '第 7 关', 'fileName': 'testData6', 'area': '5', 'id': 6},
      {'title': '第 8 关', 'fileName': 'testData7', 'area': '5', 'id': 7},
      {'title': '第 9 关', 'fileName': 'testData8', 'area': '5', 'id': 8},
      {'title': '第 10 关', 'fileName': 'testData9', 'area': '5', 'id': 9},
      {'title': '第 11 关', 'fileName': 'testData10', 'area': '5', 'id': 10},
      {'title': '第 12 关', 'fileName': 'testData11', 'area': '5', 'id': 11},
      {'title': '第 13 关', 'fileName': 'testData12', 'area': '5', 'id': 12},
      {'title': '第 14 关', 'fileName': 'testData13', 'area': '5', 'id': 13},
      {'title': '第 15 关', 'fileName': 'testData14', 'area': '5', 'id': 14},
      {'title': '第 16 关', 'fileName': 'testData15', 'area': '5', 'id': 15}
    ];
//    getFiles();
  }

  getFiles() async {
    Directory directory = await getExternalStorageDirectory();
    Directory createData = Directory('${directory.path}/createData');
    var fileData = createData.listSync().map((e) {
      var name = e.path.split('/').last.split('.').first;
      var v = name.split('a').last.split('_');
      var num = int.parse(v.first);
      var line = v.last;
      return {
        'title': '第 ${num + 1} 关',
        'fileName': 'testData$num',
        'area': line,
        'id': num
      };
    }).toList();
    fileData.sort((dynamic a, dynamic b) => a['id'].compareTo(b['id']));
    setState(() {
      data.addAll(fileData);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('关卡列表'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var item = data[index];
                  return ListTile(
                    title: Text(
                      item['title'],
                      style: TextStyle(fontSize: 20),
                    ),
                    leading: Text('${item['area']} x ${item['area']}'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CustomRouteRect(item['title'], item['id']);
                    })),
                  );
                }),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: GestureDetector(
              onTap: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CustomEdit(data.length);
              })),
              child: Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Center(
                  child: Text(
                    '编辑',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
