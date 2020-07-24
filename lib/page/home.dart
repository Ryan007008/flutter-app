import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/page/daily/daily.dart';
import 'package:flutterapp/page/library/library.dart';
import 'package:flutterapp/page/mywork/my_work.dart';
import 'package:flutterapp/page/news/news.dart';
import 'package:flutterapp/page/test/list.dart';
import 'package:flutterapp/r.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController _controller;
  List<Widget> _widgetOptions = [
    LibraryPage(),
    DailyList(),
    NewsPage(),
    MyWorkList(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              children: _widgetOptions,
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            Positioned(
              right: 10,
              bottom: 150,
              child: Offstage(
                offstage: inProduction,
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return ListPage();
                  })),
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Text('新关卡',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(R.assetsImagesIcTabGalleryGrey,
                  width: 25, height: 25),
              activeIcon: Image.asset(R.assetsImagesIcTabGalleryHighlight,
                  width: 25, height: 25),
              title: Text('Library',
                  style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10))),
          BottomNavigationBarItem(
            icon: Image.asset(R.assetsImagesIcTabDailyGrey,
                width: 25, height: 25),
            activeIcon: Image.asset(R.assetsImagesIcTabDailyHighlight,
                width: 25, height: 25),
            title: Text('Daily',
                style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset(R.assetsImagesIcTabNewsGrey, width: 25, height: 25),
            activeIcon: Image.asset(R.assetsImagesIcTabNewsHighlight,
                width: 25, height: 25),
            title: Text('News',
                style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(R.assetsImagesIcTabMyworkGrey,
                width: 25, height: 25),
            activeIcon: Image.asset(R.assetsImagesIcTabMyworkHighlight,
                width: 25, height: 25),
            title: Text('Gallery',
                style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    _controller.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }
}
