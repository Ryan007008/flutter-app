import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/page/daily/daily.dart';
import 'package:flutterapp/page/library/library.dart';
import 'package:flutterapp/page/mywork/my_work.dart';
import 'package:flutterapp/page/news/news.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: 0);
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const List<Widget> _widgetOptions = <Widget>[
      LibraryPage(),
      DailyList(),
      NewsPage(),
      MyWorkList(),
    ];

    void _onItemTapped(int index) {
      _controller.jumpToPage(index);
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: PageView(
          children: _widgetOptions,
          controller: _controller,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(R.imagesIcTabGalleryGrey, width: 25, height: 25),
            activeIcon: Image.asset(R.imagesIcTabGalleryHighlight, width: 25, height: 25),
            title: Text('Library', style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10))
          ),
          BottomNavigationBarItem(
            icon: Image.asset(R.imagesIcTabDailyGrey, width: 25, height: 25),
            activeIcon: Image.asset(R.imagesIcTabDailyHighlight, width: 25, height: 25),
            title: Text('Daily', style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(R.imagesIcTabNewsGrey, width: 25, height: 25),
            activeIcon: Image.asset(R.imagesIcTabNewsHighlight, width: 25, height: 25),
            title: Text('News', style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(R.imagesIcTabMyworkGrey, width: 25, height: 25),
            activeIcon: Image.asset(R.imagesIcTabMyworkHighlight, width: 25, height: 25),
            title: Text('Gallery', style: TextStyle(color: Color(0xFFFD6F6F), fontSize: 10)),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}