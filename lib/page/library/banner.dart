import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/r.dart';

class LibraryBanner extends StatefulWidget {
  const LibraryBanner();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LibraryBannerState();
  }
}

class LibraryBannerState extends State<LibraryBanner> {
  PageController controller;
  int selectedIndex;
  int length;
  double imageWidth;
  double imageHeight;
  int seconds;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    imageWidth = window.physicalSize.width - 30;
    imageHeight = imageWidth / (346 / 152);
    length = 3;
    selectedIndex = length * 5;
    controller = PageController(initialPage: selectedIndex);
    var now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 23, 59, 59);
    seconds = next
        .difference(now)
        .inSeconds;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds--;
      });
      if (seconds == 0) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var banner = getBanner(context);
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: getPageView(banner),
          height: MediaQuery
              .of(context)
              .size
              .width / (346 / 152),
        ),
        Positioned(
          right: 0.0,
          top: 0.0,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/setting');
            },
            child: Container(
              width: 44,
              height: 44,
              child: Image.asset(R.assetsImagesIcAllSet),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> getBanner(BuildContext context) {
    var imageWidth = MediaQuery
        .of(context)
        .size
        .width - 30;
    var imageHeight = imageWidth / (346 / 152);
    return [
      Container(
        child: Center(
          child: Stack(
            children: [
              Container(
                child: Image.asset(R.assetsImagesIcCarouselNew,
                    fit: BoxFit.cover, width: imageWidth, height: imageHeight),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('NEW FREE PICTURE IN',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(
                      formatTime(seconds),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 34),
                    ),
                  ],
                ),
                width: imageWidth * 0.6,
                height: imageHeight,
              )
            ],
          ),
        ),
      ),
      Container(
        child: Center(
          child: Stack(
            children: [
              Container(
                child: Image.asset(R.assetsImagesIcCarouselFacebook,
                    fit: BoxFit.cover, width: imageWidth, height: imageHeight),
              ),
              Container(
                height: imageHeight,
                padding:
                const EdgeInsets.symmetric(vertical: 34, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      child: Text('Exclusive images',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontStyle: FontStyle.italic)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2.0),
                      child: Text('Only on our Facebook page',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontStyle: FontStyle.italic)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11, left: 8),
                      child: DecoratedBox(
                        child: Container(
                          width: 90,
                          height: 24,
                          child: Center(
                            child: Text(
                              'Open',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFB7B17),
                                Color(0xFFF34921),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      Container(
        child: Center(
          child: Stack(
            children: [
              Container(
                child: Image.asset(R.assetsImagesIcCarouselSub,
                    fit: BoxFit.cover, width: imageWidth, height: imageHeight),
              )
            ],
          ),
        ),
      )
    ];
  }

  Widget getPageView(List<Widget> banners) {
    return PageView.builder(
//      itemCount: data.length,
      controller: controller,
      itemBuilder: (context, index) {
        return banners.elementAt(index % length);
      },
      onPageChanged: (index) {
//        setState(() {
        selectedIndex = index;
        if (index == 0) {
          selectedIndex = length;
          controller.jumpToPage(selectedIndex);
        }
//        });
      },
    );
  }

  String formatTime(int seconds) {
    var h = (seconds / 3600).floor();
    var m = ((seconds - (h * 3600)) / 60).floor();
    var s = seconds - (h * 3600) - (m * 60);
    var HH = h < 10 ? '0$h' : '$h';
    var mm = m < 10 ? '0$m' : '$m';
    var ss = s < 10 ? '0$s' : '$s';
    return '$HH:$mm:$ss';
  }
}
