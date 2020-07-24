import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/page/class/templateManager.dart';
import 'package:flutterapp/page/daily/header.dart';
import 'package:flutterapp/page/paint/painting.dart';
import 'package:flutterapp/r.dart';

class DailyList extends StatefulWidget {
  const DailyList();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DailyListState();
  }
}

class DailyListState extends State<DailyList>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;
  Map<String, List<Template>> data = Map();
  List<Template> headers = [];
  bool loading = true;
  TemplateManager manager = TemplateManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ScrollController(initialScrollOffset: 0.0);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (loading) {
      return Container(
        child: Center(
          child: SpinKitCircle(
            color: Color(0xFFFD6F6F),
          ),
        ),
      );
    }
    return getDailyList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  getData() async {
    await manager.syncRemoteLibrary();
    var dailies = await manager.getDaily();
    dailies.sort((a, b) => b.openDate - a.openDate);
    var dataMap = Map<String, List<Template>>();
    dailies.forEach((element) {
      var date = DateTime.fromMillisecondsSinceEpoch(element.openDate * 1000);
      var m = DateTime(date.year, date.month).toIso8601String();
      if (!dataMap.containsKey(m)) {
        dataMap[m] = [];
      }
      dataMap[m].add(element);
    });
    setState(() {
      data = dataMap;
      headers = manager.dailyHeaders;
      loading = false;
    });
  }

  Widget getDailyList() {
    var list = getBoxAdapter();
    list.insert(0, SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: headers.length > 0 ? DailyHeader(headers) : Container(),
        height: 314,
      ),
    ));
    return CustomScrollView(
      slivers: list
    );
  }

  List<Widget> getBoxAdapter() {
    var lists = data.entries.toList();
    lists.sort((a, b) {
      return DateTime.parse(b.key).millisecondsSinceEpoch - DateTime.parse(a.key).millisecondsSinceEpoch;
    }) ;
    return lists.map((e) => SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Container(
           child: Center(
             child: Text('${DateTime.parse(e.key).month}月', style: TextStyle(fontSize: 18)),
           ),
           height: 40,
           width: 60,
//           padding: const EdgeInsets.symmetric(horizontal: 15.0),
         ),
          getList(e.value)
        ],
      ),
    )).toList();
  }

  Widget getList(List<Template> templates) {
    var imageWidth = (MediaQuery.of(context).size.width - 30) / 2;
    return GridView.builder(
        primary: false,
        shrinkWrap: true,
        cacheExtent: 2.0,
        padding: const EdgeInsets.all(0.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: templates.length,
        controller: _controller,
        itemBuilder: (context, index) {
          Template template = templates[index];
          var day =
              DateTime.fromMillisecondsSinceEpoch(template.openDate * 1000).day;
          return GestureDetector(
              onTap: () => onTapItem(template.id, ''),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                shadowColor: Color(0xFF5D5572),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.contain,
                      width: imageWidth,
                      height: imageWidth,
                      imageUrl: template.url,
                      placeholder: (context, url) => SpinKitCircle(
                        color: Color(0xFFFD6F6F),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 33,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10.0)),
                              child: Image.asset(R.assetsImagesIcDailyItemCorner),
                            ),
                            Positioned(
                              right: 10,
                              bottom: 2,
                              child: Text('$day',
                                  style: TextStyle(
                                      color: Color(0xFF7A7B85), fontSize: 16)),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  Future onTapItem(String id, String categoryId) async {
    print('id: $id');
    Template template = await manager.getTemplateById(id);
    if (template != null) {
      await manager.download(id, template.hash);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaintingPage(id, categoryId, template.tags);
      }));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
