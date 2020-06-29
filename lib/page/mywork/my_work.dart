import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/page/class/Template.dart';
import 'package:flutterapp/r.dart';

class MyWorkList extends StatefulWidget {
  const MyWorkList();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyWorkListState();
  }
}

class MyWorkListState extends State<MyWorkList>
    with AutomaticKeepAliveClientMixin {
  PageController _pageController;
  int _selectedIndex;
  double _offsetX = 0;
  double itemWidth = 0;
  double screenWidth = 0;
  List<Template> myWork = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(initialPage: 0);
    _selectedIndex = 0;
    _pageController.addListener(() {
      var current = _pageController.offset / screenWidth;
      setState(() {
        _offsetX = itemWidth / 2 * current;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    screenWidth = MediaQuery.of(context).size.width;
    itemWidth = screenWidth * 0.64;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color(0x22000008),
                offset: Offset(0.0, 1.0),
                blurRadius: 0.0,
                spreadRadius: 0.0)
          ]),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(R.imagesIcAchievement),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19.0),
                          border:
                              Border.all(color: Color(0xFFFD6F6F), width: 2.0)),
                      child: Stack(
                        children: [
                          Transform.translate(
                            offset: Offset(_offsetX, 0),
                            child: ClipRRect(
                                child: Container(
                                  color: Color(0xFFFD6F6F),
                                  height: 38,
                                  width: itemWidth / 2,
                                ),
                                borderRadius: BorderRadius.circular(19.0)),
                          ),
                          Container(
                            height: 38,
                            width: itemWidth,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = 0;
                                      _pageController.jumpToPage(0);
                                    });
                                  },
                                  child: Container(
                                    width: itemWidth / 2,
                                    child: Center(
                                      child: Text('未完成',
                                          style: TextStyle(
                                              color: _selectedIndex == 0
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 1;
                                        _pageController.jumpToPage(1);
                                      });
                                    },
                                    child: Container(
                                      width: itemWidth / 2,
                                      child: Center(
                                        child: Text('已完成',
                                            style: TextStyle(
                                                color: _selectedIndex == 1
                                                    ? Colors.white
                                                    : Colors.black)),
                                      ),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/setting');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(R.imagesIcSet),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: PageView(
            children: [
              myWork.length > 0
                  ? Center(
                      child: Text('0'),
                    )
                  : getEmpty(),
              myWork.length > 0
                  ? Center(
                      child: Text('1'),
                    )
                  : getEmpty()
            ],
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
//                _offsetX = index == 1 ? itemWidth / 2 : 0;
              });
            },
          ),
        )
      ],
    );
  }

  getEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          R.imagesPicEmptyMywork,
          fit: BoxFit.cover,
          width: 225,
          height: 178,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            "No artwork here,it's time to start your\ncoloring journey from the Library.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
