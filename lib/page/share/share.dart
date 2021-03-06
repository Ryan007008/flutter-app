import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/r.dart';

class SharePage extends StatefulWidget {
  final String filePath;
  final bool isWallpaper;

  SharePage(this.filePath, this.isWallpaper);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SharePageState();
  }
}

class SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var imgWidth = MediaQuery.of(context).size.width * (widget.isWallpaper ? 0.6 : 0.8);
    var imgHeight = widget.isWallpaper ? imgWidth / (478 / 850) : imgWidth;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Share',
          style: TextStyle(color: Color(0xFF333333), fontSize: 16),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            height: 32,
            child: Image.asset(R.assetsImagesIcActionBack),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Image.file(File(widget.filePath)),
            width: imgWidth,
            height: imgHeight,
            margin: const EdgeInsets.symmetric(vertical: 20.0),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    child: Column(
                      children: [
                        Image.asset(R.assetsImagesIcShareSave, width: 55, height: 55,),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text('Save', style: TextStyle(color: Color(0xFF333333), fontSize: 14),),
                        )
                      ],
                    ),
                    width: 80,
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Column(
                      children: [
                        Image.asset(R.assetsImagesIcShareInstagram, width: 55, height: 55,),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text('Instagram', style: TextStyle(color: Color(0xFF333333), fontSize: 14),),
                        )
                      ],
                    ),
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Column(
                      children: [
                        Image.asset(R.assetsImagesIcShareShare, width: 55, height: 55,),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text('More', style: TextStyle(color: Color(0xFF333333), fontSize: 14),),
                        )
                      ],
                    ),
                    width: 80,
                  ),
                ),
              ],
            ),
            height: 90,
            margin: const EdgeInsets.only(bottom: 50.0),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: Container(
              child: Center(
                child: Text('继续', style: TextStyle(color: Colors.white, fontSize: 25),),
              ),
              width: 200,
              height: 62,
              decoration: BoxDecoration(
                  color: Color(0xFFFD6F6F),
                  boxShadow: [BoxShadow(color: Color(0xFFFD6F6F), offset: Offset(1.0, 2.0), blurRadius: 5.0, spreadRadius: 1.0)],
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }
}
