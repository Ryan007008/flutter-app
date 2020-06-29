import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterapp/page/class/TemplateManager.dart';
import 'package:flutterapp/r.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaintingPage extends StatefulWidget {
  final String id;
  final String categoryId;

  const PaintingPage(this.id, this.categoryId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PaintingPageState();
  }
}

class PaintingPageState extends State<PaintingPage> {
  TemplateManager manager = TemplateManager();
  WebViewController _webController;
  int hintCount = 0;
  List<String> paletteColors = [];
  Map<String, dynamic> colorGroup;
  int paletteSelected = 0;
  File svgPath;
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    manager.getDownloadPath().then((value) {
      var fileJson = File('$value/${widget.id}.json');
      var data = jsonDecode(fileJson.readAsStringSync());
      setState(() {
        paletteColors = data['palette'].cast<String>().toList();
        colorGroup = data['colorGroup'];
        svgPath = File('$value/${widget.id}.svg');
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String url =
        'file:///android_asset/flutter_assets/images/miniapp/index.html?bgcolor=ffffff';
    if (widget.categoryId == 'wallpaper') {
      url =
          'file:///android_asset/flutter_assets/images/miniapp/index_wallpaper.html?bgcolor=ffffff';
    }

    if (loading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              getTitleBar(),
              Expanded(
                child: Center(
                  child: SpinKitCircle(
                    color: Color(0xFFFD6F6F),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            getTitleBar(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: WebView(
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (webController) {
                    _webController = webController;
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    manager.getDownloadPath().then((path) {
                      var svgFile = File('$path/${widget.id}.svg');
                      _webController.evaluateJavascript(
                          'TintageController.setSvgUrl("${svgFile.path}");true;');
                      var imgFile = File('$path/${widget.id}_tear_film.png');
                      if (imgFile.existsSync()) {
                        _webController.evaluateJavascript(
                            'TintageController.setImageUrl("${imgFile.path}");true;');
                      }
                    });
                  },
                ),
              ),
            ),
            getPaletteColors()
          ],
        ),
      ),
    );
  }

  Widget getTitleBar() => Container(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                height: 32,
                child: Image.asset(R.imagesIcActionBack),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('AAA'),
              ),
            ),
            GestureDetector(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(color: Color(0xFFFFEDED), width: 2.0)),
                child: Container(
                  height: 44.0,
                  width: 44.0,
                  child: Center(
                    child:
                        Text('0%', style: TextStyle(color: Color(0xFFFF7F7F))),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget getHint() => GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                height: 84.0,
                width: 84.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                        border:
                            Border.all(color: Color(0xFFff9800), width: 2.0)),
                    height: 64.0,
                    width: 64.0,
                    child: Center(
                      child: Image.asset(
                        R.imagesIcHint,
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                )),
            Positioned(
              right: 2.0,
              top: 10.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFff9800),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  height: 18,
                  child: Text('3',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      );

  Widget getPaletteColors() {
    return Container(
      color: Color(0xFFFBFAFC),
      height: 84,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getHint(),
          Expanded(
            child: Container(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: paletteColors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          paletteSelected = index;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: paletteSelected == index ? 55 : 40,
                            height: paletteSelected == index ? 55 : 40,
                            child: CircularProgressIndicator(
                              backgroundColor: Color(0xFFCCCCCC),
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFF0AE682)),
//                          valueColor: Color(0xFF0AE682),
                              value: 0.5,
                              strokeWidth: 5,
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: getBoxDecoration(paletteColors[index]),
                            width: 50.0,
                            height: 50.0,
                            child: Center(
                              child: Text('${index + 1}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          paletteSelected == index ? 26 : 20)),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  BoxDecoration getBoxDecoration(String value) {
    if (value.contains(':')) {
      if (value.startsWith('r')) {
        return BoxDecoration(
            gradient: getRadialGradient(value),
            borderRadius: BorderRadius.circular(25.0));
      }
      if (value.startsWith('v')) {
        return BoxDecoration(
            gradient: getLinearGradient(
                value, Alignment.topCenter, Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(25.0));
      }
      if (value.startsWith('h')) {
        return BoxDecoration(
            gradient: getLinearGradient(
                value, Alignment.centerLeft, Alignment.centerRight),
            borderRadius: BorderRadius.circular(25.0));
      }
    }
    return BoxDecoration(
        color: Color(int.parse('0xFF${value.substring(1)}')),
        borderRadius: BorderRadius.circular(25.0));
  }
}

LinearGradient getLinearGradient(String value, Alignment begin, Alignment end) {
  var colorType = value.substring(0, 1);
  var colors = value.substring(2).split(',');
  var colorStart = colors[0];
  var colorEnd = colors[1];
  print('aaaa: $colorType, $colorStart, $colorEnd');
  return LinearGradient(begin: begin, end: end, colors: [
    Color(int.parse('0xFF${colorStart.substring(1)}')),
    Color(int.parse('0xFF${colorEnd.substring(1)}')),
  ]);
}

RadialGradient getRadialGradient(String value) {
  var colorType = value.substring(0, 1);
  var colors = value.substring(2).split(',');
  var colorStart = colors[0];
  var colorEnd = colors[1];
  print('aaaa: $colorType, $colorStart, $colorEnd');
  return RadialGradient(colors: [
    Color(int.parse('0xFF${colorStart.substring(1)}')),
    Color(int.parse('0xFF${colorEnd.substring(1)}')),
  ]);
}
