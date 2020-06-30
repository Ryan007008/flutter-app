import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/page/class/Template.dart';
import 'package:flutterapp/r.dart';

class DailyHeader extends StatefulWidget {
  final List<Template> headers;

  DailyHeader(this.headers);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DailyHeaderState();
  }
}

class DailyHeaderState extends State<DailyHeader>
    with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  double angle = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animation = new Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        print('value: ' + animation.value.toString());
        setState(() {
          angle = animation.value;
        });
      });
//    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          child: Image.asset(R.imagesDaliyWatermark),
          width: 340,
        ),
        DecoratedBox(
          position: DecorationPosition.foreground,
          child: Container(
            width: 238,
            height: 238,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.contain,
                      width: 228,
                      height: 228,
                      imageUrl: widget.headers[0].url,
                      placeholder: (context, url) =>
                          Image.asset(R.imagesPicCellPlaceholder),
                    ),
                    Image.network(
                      widget.headers[0].url,
                      fit: BoxFit.cover,
                      width: 228,
                      height: 228,
                    ),
                    Opacity(
                      opacity: 0.93,
                      child: Image.asset(R.imagesDailyBlur,
                          fit: BoxFit.cover, width: 228, height: 228),
                    ),
                    Transform.scale(
                      scale: angle,
                      child: Image.asset(R.imagesDailyGift,
                          fit: BoxFit.contain, width: 150, height: 150),
                    )
                  ],
                ),
              ),
            ),
          ),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFfd6f6f), width: 5.0),
              borderRadius: BorderRadius.circular(22.0)),
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
              child: Image.asset(R.imagesIcAllSet),
            ),
          ),
        )
      ],
    );
  }
}
