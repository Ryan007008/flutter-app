import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterapp/page/class/Template.dart';
import 'package:flutterapp/page/class/TemplateManager.dart';
import 'package:flutterapp/page/library/banner.dart';
import 'package:flutterapp/page/library/categroy_list.dart';
import 'package:flutterapp/page/paint/painting.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LibraryState();
  }
}

class LibraryState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<Template>> data;
  ScrollController _tabController;
  PageController _pageController;

  int _selectedIndex;
  TemplateManager manager = TemplateManager();
  bool loading = true;
  double _scrollToOffsetY = 0;

  @override
  void initState() {
    super.initState();
    data = new Map();
    _tabController = ScrollController(initialScrollOffset: 0.0);
    _pageController = PageController(initialPage: 0);
    _selectedIndex = 0;
    getData();
  }

  getData() async {
    await manager.syncRemoteLibrary();
    setState(() {
      data = manager.getGallery();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Stack(children: [
          PageView(
            children: getTabBarViews(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index >= 2 && index < data.length - 2) {
                _tabController.animateTo((index - 2) * 80.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear);
              }
            },
          ),
          Transform.translate(
            offset: Offset(0, -_scrollToOffsetY),
            child: Container(
              child: Column(
                children: [
                  LibraryBanner(),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                          color: Color(0x22000008),
                          offset: Offset(0.0, 1.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0)
                    ]),
                    child: getTabBars(),
                    height: 48,
                  )
                ],
              ),
            ),
          )
        ]),
        loading
            ? Container(
                child: Center(
                  child: SpinKitCircle(
                    color: Color(0xFFFD6F6F),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  ListView getTabBars() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _tabController,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.jumpToPage(index);
            },
            child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Center(
                child: ClipRRect(
                  child: Container(
                    color: _selectedIndex == index
                        ? Color(0xFFFD6F6F)
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        TemplateManager
                            .categoryNames[data.keys.toList()[index]],
                        style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: _selectedIndex == index
                                ? FontWeight.w700
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          );
        });
  }

  List<Widget> getTabBarViews() {
    return data.entries
        .map((e) => CategoryList(
              data: e.value,
              categoryId: e.key,
              onTap: onTapItem,
              scrollToOffsetY: _scrollToOffsetY,
              getOffset: (offset) => setState(() {
                print('offset: $offset');
                _scrollToOffsetY = offset;
              }),
            ))
        .toList();
  }

  Future onTapItem(String id, String categoryId) async {
    print('id: $id');
    setState(() {
      loading = true;
    });
    Template template = await manager.getTemplateById(id);
    if (template != null) {
      await manager.download(id, template.hash);
      setState(() {
        loading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaintingPage(id, categoryId, template.tags);
      }));
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
