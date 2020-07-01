import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutterapp/page/class/TemplateManager.dart';
import 'package:flutterapp/r.dart';

class PaintingPage extends StatefulWidget {
  final String id;
  final String categoryId;
  final String tags;

  const PaintingPage(this.id, this.categoryId, this.tags);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PaintingPageState();
  }
}

class PaintingPageState extends State<PaintingPage> {
  TemplateManager manager = TemplateManager();
  int hintCount = 0;
  List<String> paletteColors = [];
  Map<String, dynamic> colorGroup;
  Map<String, Set<String>> fillColors = new Map();
  int paletteSelected = 0;
  File svgPath;
  File imagePath;
  bool loading = true;
  final flutterWebViewPlugin = FlutterWebviewPlugin();

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
        print('colorGroup: $colorGroup');
        svgPath = File('$value/${widget.id}.svg');
        imagePath = File('$value/${widget.id}_tear_film.png');
        loading = false;
      });
    });
    flutterWebViewPlugin.onStateChanged.listen((event) {
      if (event.type == WebViewState.finishLoad) {
        flutterWebViewPlugin.evalJavascript(
            'TintageController.setSvgUrl("${svgPath.path}");true;');
        print('imagePath: ${imagePath.existsSync()}');
        if (imagePath.existsSync()) {
          flutterWebViewPlugin.evalJavascript(
              'TintageController.setImageUrl("${imagePath.path}");true;');
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    flutterWebViewPlugin.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String url =
        'file:///android_asset/flutter_assets/images/dist/index.html?bgcolor=ffffff';
    if (widget.tags.contains('wallpaper')) {
      url =
          'file:///android_asset/flutter_assets/images/dist/index_wallpaper.html?bgcolor=ffffff';
    }

    if (loading) {
      return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () {
                  flutterWebViewPlugin.hide();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  height: 32,
                  child: Image.asset(R.imagesIcActionBack),
                ),
              )),
          body: SafeArea(
            child: Center(
              child: SpinKitCircle(
                color: Color(0xFFFD6F6F),
              ),
            ),
          ));
    }

    return WebviewScaffold(
      url: url,
      withZoom: true,
      withLocalUrl: true,
      withLocalStorage: true,
      withJavascript: true,
      allowFileURLs: true,
      hidden: true,
      scrollBar: false,
      javascriptChannels: <JavascriptChannel>[
        JavascriptChannel(
            name: 'ReactNativeWebView',
            onMessageReceived: (JavascriptMessage message) {
              print('message: ${message.message}');
              onRecvWebviewMsg(message);
            })
      ].toSet(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            flutterWebViewPlugin.hide();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            height: 32,
            child: Image.asset(R.imagesIcActionBack),
          ),
        ),
        actions: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: Color(0xFFFFEDED), width: 2.0)),
              child: Container(
                height: 44.0,
                width: 44.0,
                child: Center(
                  child: Text('0%', style: TextStyle(color: Color(0xFFFF7F7F))),
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: getPaletteColors(),
    );
  }

  void sentMsgToWeb(dynamic msg) {
    var m = jsonEncode(msg);
    print('msg: $m');
    flutterWebViewPlugin.evalJavascript('window.postMessage($m, "*");true;');
  }

  void onRecvWebviewMsg(JavascriptMessage message) {
    var msg = jsonDecode(message.message);
    var type = msg['type'];
    var payload = msg['payload'];
    switch (type) {
      case 'ACT_ONINJECTED_SVG':
        var msg = {
          "type": "ACT_RECOVERY_STATE",
          "payload": {
            "colorState": {"colorIdx": 0, "colorVal": paletteColors[0]},
            "steps": []
          }
        };
        sentMsgToWeb(msg);
        break;
      case 'ACT_ONDRAWED_COLOR':
        var colorVal = payload['colorState']['colorVal'];
        var pathIds = payload['colorState']['pathIds'] as List;
        saveStep(colorVal, pathIds);
        break;
    }
  }

  void saveStep(String colorVal, List<String> pathIds) {
    setState(() {
      if (fillColors.containsKey(colorVal)) {
        fillColors[colorVal].addAll(pathIds);
      } else {
        fillColors[colorVal] = pathIds.toSet();
      }
    });
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
                    var color = paletteColors[index];
                    var allIds = (colorGroup[color] as List).length;
                    var finishedIds = fillColors[color]?.length;
                    print('allIds: $allIds');
                    print('finishedIds: $finishedIds');
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          paletteSelected = index;
                        });
                        var msg = {
                          "type": "ACT_COLOR_STATE",
                          "payload": {
                            "colorIdx": index,
                            "colorVal": color,
                          },
                        };
                        sentMsgToWeb(msg);
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
                              value: (finishedIds ?? 0 / allIds),
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
