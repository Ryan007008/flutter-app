import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterapp/page/class/Template.dart';
import 'package:flutterapp/page/class/TemplateManager.dart';
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
  List<Template> data;
  List<Template> headers;
  bool loading = true;
  TemplateManager manager = TemplateManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ScrollController(initialScrollOffset: 0.0);
    data = [];
    headers = [];
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
    setState(() {
      data = dailies;
      headers = manager.dailyHeaders;
      loading = false;
    });
  }

  Widget getDailyList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: DailyHeader(headers),
            height: 314,
          ),
        ),
        SliverToBoxAdapter(
          child: getList(),
        )
      ],
    );
  }

  Widget getList() {
    var imageWidth = (MediaQuery.of(context).size.width - 30) / 2;
    return GridView.builder(
        primary: false,
        shrinkWrap: true,
        cacheExtent: 2.0,
        padding: const EdgeInsets.all(0.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: data.length,
        controller: _controller,
        itemBuilder: (context, index) {
          Template template = data[index];
          var day =
              DateTime.fromMillisecondsSinceEpoch(template.openDate * 1000).day;
          return GestureDetector(
            onTap: () => onTapItem(template.id, ''),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      width: imageWidth,
                      height: imageWidth,
                      imageUrl: template.url,
                      placeholder: (context, url) => SpinKitCircle(
                        color: Color(0xFFFD6F6F),
                      ),
                    ),
                  ),
                  width: imageWidth,
                  height: imageWidth,
//                padding: const EdgeInsets.all(5.0),
                ),
                Positioned(
                  right: 7.5,
                  bottom: 7.5,
                  child: Container(
                    width: 33,
                    height: 28,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black26, width: 0.5),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0))),
                    child: Center(
                      child: Text('$day',
                          style:
                          TextStyle(color: Color(0xFF7A7B85), fontSize: 16)),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future onTapItem(String id, String categoryId) async {
    print('id: $id');
    Template template = await manager.getTemplateById(id);
    if (template != null) {
      await manager.download(id, template.hash);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PaintingPage(id, categoryId);
          }
      ));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
