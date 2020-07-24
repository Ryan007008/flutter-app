import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterapp/page/class/template.dart';
import 'package:flutterapp/r.dart';

class CategoryList extends StatefulWidget {
  final List<Template> data;
  final String categoryId;
  final Function(String id, String categoryId) onTap;
  final double scrollToOffsetY;
  final Function(double offset) getOffset;

  CategoryList(
      {this.data,
      this.categoryId,
      this.onTap,
      this.scrollToOffsetY,
      this.getOffset})
      : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CategoryListState();
  }
}

class CategoryListState extends State<CategoryList> {
  ScrollController _listController;

  @override
  void initState() {
    // TODO: implement initState
    _listController =
        ScrollController(initialScrollOffset: widget.scrollToOffsetY)
          ..addListener(() {
            var height = MediaQuery.of(context).size.width / (346 / 152);
            if (_listController.offset < height) {
              widget.getOffset(_listController.offset);
            } else {
              widget.getOffset(height);
            }
          });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var imageWidth = (MediaQuery.of(context).size.width - 30) / 2;
    var imageHeight = widget.categoryId == 'wallpaper'
        ? imageWidth / (478 / 850)
        : imageWidth;
    var paddingHeight = MediaQuery.of(context).size.width / (346 / 152) + 48;
    return GridView.builder(
        key: Key(widget.categoryId),
        primary: false,
        shrinkWrap: true,
        cacheExtent: 2.0,
        padding: EdgeInsets.only(top: paddingHeight),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: widget.categoryId == 'wallpaper' ? 478 / 850 : 1),
        itemCount: widget.data.length,
        controller: _listController,
        itemBuilder: (context, index) {
          Template template = widget.data[index];
          var tag = '';
          var tagWidth = 26.0;
          if (template.isNew) {
            tag = R.assetsImagesIcBadgeNew;
          }
          if (template.isSpecial) {
            tag = R.assetsImagesIcBadgeSpecial;
            tagWidth = 42.0;
          }
          if (template.jigsawId.isNotEmpty && template.jigsawNum == 1) {
            tag = R.assetsImagesIcBadgeJigsaw;
          }
          if (template.tags.contains('wallpaper')) {
            tag = R.assetsImagesIcBadgeWallpaper;
          }

          return GestureDetector(
            onTap: () => widget.onTap(template.id, widget.categoryId),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              shadowColor: Color(0xFF5D5572),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: imageWidth,
                    height: imageHeight,
                    imageUrl: template.url,
                    placeholder: (context, url) => SpinKitCircle(
                      color: Color(0xFFFD6F6F),
                    ),
                  ),
                  Positioned(
                    left: 10.0,
                    top: 10.0,
                    child: tag.isNotEmpty
                        ? Image.asset(
                            tag,
                            width: tagWidth,
                            height: 14.0,
                          )
                        : Placeholder(
                            color: Colors.transparent,
                            strokeWidth: 0,
                          ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    child: Text(template.id),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _listController.dispose();
    super.dispose();
  }
}
