import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutterapp/page/class/TemplateManager.dart';
import 'package:flutterapp/page/paint/palette_color.dart';
import 'package:flutterapp/page/share/share.dart';
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
  Map<String, Set<String>> fillColors = new LinkedHashMap();
  int paletteSelected = 0;
  File svgPath;
  File imagePath;
  bool loading = true;
  bool isWallpaper = false;
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isWallpaper = widget.tags.contains('wallpaper');
    manager.getDownloadPath().then((value) {
      var fileJson = File('$value/${widget.id}.json');
      var data = jsonDecode(fileJson.readAsStringSync());
      setState(() {
        paletteColors = List<String>.from(data['palette']);
        colorGroup = data['colorGroup'];
        svgPath = File('$value/${widget.id}.svg');
        imagePath = File('$value/${widget.id}_tear_film.png');
        loading = false;
        paletteColors.forEach((element) {
          fillColors[element] = Set<String>.from([]);
        });
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
    if (isWallpaper) {
      url =
          'file:///android_asset/flutter_assets/images/dist/index_wallpaper.html?bgcolor=ffffff';
    }

    return WebviewScaffold(
      url: url,
      withZoom: true,
      withLocalUrl: true,
      withLocalStorage: true,
      withJavascript: true,
      allowFileURLs: true,
      hidden: loading,
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
        var pathIds = payload['pathIds'] as List;
        saveStep(colorVal, pathIds);
        break;
      case 'TOAPP_LONG_TAP':
        var colorIdx = payload['colorState']['colorIdx'];
        setState(() {
          paletteSelected = colorIdx;
        });
        var msg = {
          "type": "ACT_RECOVERY_STATE",
          "payload": {
            "colorState": {
              "colorIdx": colorIdx,
              "colorVal": paletteColors[colorIdx]
            },
            "steps": []
          }
        };
        sentMsgToWeb(msg);
        break;
      case 'ACT_ONEXPORT_IMAGE':
        manager.getSaveImagePath().then((value) {
          var file = File('$value/${widget.id}.png');
          if (!file.existsSync()) {
            file.createSync();
          }
          var content = (payload['content'] as String)
              .substring('data:image/png;base64,'.length);
          file.writeAsBytesSync(base64.decode(content));
          flutterWebViewPlugin.close();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SharePage(file.path, isWallpaper);
          }));
        });

        break;
    }
  }

  void findNext() {
    var fillIds = fillColors.values.toList()[paletteSelected].length;
    var allIds = List.from(colorGroup.values.toList()[paletteSelected]).length;
    if (fillIds == allIds) {
      var nextIndex = -1;
      for(var i = paletteSelected + 1; i < paletteColors.length; i++) {
        var fillIds = fillColors.values.toList()[i].length;
        var allIds = List.from(colorGroup.values.toList()[i]).length;
        if (fillIds != allIds) {
          nextIndex = i;
          break;
        }
      }

      if (nextIndex < 0) {
        var msg = {
          "type": "ACT_EXPORT_CANVAS",
          "payload": {"contentType": "base64png", "postAction": "finish"}
        };
        sentMsgToWeb(msg);
        return;
      }
      setState(() {
        paletteSelected = nextIndex;
      });
      var msg = {
        "type": "ACT_COLOR_STATE",
        "payload": {
          "colorIdx": paletteSelected,
          "colorVal": paletteColors[paletteSelected],
        },
      };
      sentMsgToWeb(msg);
    }
  }

  void saveStep(String colorVal, List pathIds) {
    setState(() {
      if (fillColors.containsKey(colorVal)) {
        fillColors[colorVal].addAll(Set.from(pathIds));
      } else {
        fillColors[colorVal] = Set.from(pathIds);
      }
    });
    findNext();
  }

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
            child: PaletteColor(
                paletteColors, colorGroup, fillColors, paletteSelected,
                (index, color) {
              var msg = {
                "type": "ACT_COLOR_STATE",
                "payload": {
                  "colorIdx": index,
                  "colorVal": color,
                },
              };
              sentMsgToWeb(msg);
              setState(() {
                paletteSelected = index;
              });
              print('bbbbb: $paletteSelected');
            }),
          )
        ],
      ),
    );
  }
}
