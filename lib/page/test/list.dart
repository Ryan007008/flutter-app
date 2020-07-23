import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/page/test/customPaintRect.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListState();
  }
}

class ListState extends State<ListPage> {
  List<Map<String, String>> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = [
      {'title': '第一关', 'fileName': 'testData0', 'area': '5x5'},
      {'title': '第二关', 'fileName': 'testData1', 'area': '5x5'},
      {'title': '第三关', 'fileName': 'testData2', 'area': '5x5'},
      {'title': '第四关', 'fileName': 'testData3', 'area': '5x5'}
    ];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('关卡列表'),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
              return ListTile(
                title: Text(item['title']),
                leading: Text(item['area']),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return CustomRouteRect(item['title'], item['fileName']);
                })),
              );
            }),
      ),
    );
  }
}
