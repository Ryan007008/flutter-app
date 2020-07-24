import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterapp/page/class/templateManager.dart';
import 'package:lottie/lottie.dart';

class CustomAreaRoute extends StatefulWidget {
  final id;

  CustomAreaRoute(this.id);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomAreaRouteState();
  }
}

class CustomAreaRouteState extends State<CustomAreaRoute>
    with TickerProviderStateMixin {
  Map<int, List<String>> fillArea = LinkedHashMap();
  Map<int, bool> finishedNumber = LinkedHashMap();
  Map<int, List<String>> textAreas = LinkedHashMap();
  List<dynamic> numbers = [];
  int lines = 0;
  double boxWidth;
  int selectedPaintIndex = -1;
  TemplateManager manager = TemplateManager();
  File svgPath;
  File imagePath;
  bool loading = true;
  bool isFinishedAll = false;
  AnimationController _controller;
  bool isCompleted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
    boxWidth =
        (window.physicalSize.width / window.devicePixelRatio).floor() - 20.0;
    var r = Random().nextInt(16);
    DefaultAssetBundle.of(context)
        .loadString("assets/data/testData$r.json")
        .then((value) {
      var json = jsonDecode(value);
      manager.getDownloadPath().then((value) {
        setState(() {
          numbers = json['number'] as List;
          numbers.asMap().entries.forEach((element) {
            var areas = element.value['area'] as List;
            textAreas.putIfAbsent(element.key, () => [areas.first, areas.last]);
            fillArea.putIfAbsent(element.key, () => []);
          });
          lines = json['lines'];
          svgPath = File('$value/${widget.id}.svg');
          imagePath = File('$value/${widget.id}_tear_film.png');
          loading = false;
        });
      });
    });
    _controller.addStatusListener((status) {
      //动画状态变化回调接口
      print('aaa: $status');
      if (status == AnimationStatus.completed) {
//        setState(() {
//          isCompleted = false;
//        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (loading) {
      return Container(
        child: Center(
          child: SpinKitCircle(
            color: Color(0xFFFD6F6F),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('关卡'),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              imagePath,
              width: boxWidth,
              height: boxWidth,
              fit: BoxFit.cover,
            ),
            CustomPaint(
              size: Size(boxWidth, boxWidth),
              painter: MyPainter(numbers, fillArea, lines, selectedPaintIndex),
            ),
            GestureDetector(
              onPanStart: (d) {
                if (isFinishedAll) return;
                chooseStartArea(d.localPosition);
              },
              onPanUpdate: (d) {
                if (d.localPosition.dx < 0 ||
                    d.localPosition.dy < 0 ||
                    d.localPosition.dx > boxWidth ||
                    d.localPosition.dy > boxWidth ||
                    selectedPaintIndex < 0 ||
                    isFinishedAll) return;
                addFillArea(d.localPosition);
              },
              onPanEnd: (d) {
                if (selectedPaintIndex < 0 || isFinishedAll) return;
                finishedArea();
                if (isFinishedAll) {
                  setState(() {
                    isCompleted = true;
                  });
                  _controller.forward();
                }
              },
              child: Opacity(
                opacity: isFinishedAll ? 0 : 1,
                child: CustomPaint(
                  size: Size(boxWidth, boxWidth),
                  painter: BasePainter(numbers, lines),
                ),
              ),
            ),
            Positioned(
                top: 100,
                child: Offstage(
                  offstage: !isCompleted,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 330,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/lottie/correct.json',
                            width: 276,
                            height: 180,
                            fit: BoxFit.cover,
                            controller: _controller, onLoaded: (c) {
                          _controller.duration = c.duration;
                        }),
                        Text(
                          '太棒了',
                          style: TextStyle(color: Colors.red, fontSize: 30),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 100,
                            height: 50,
                            margin: const EdgeInsets.only(top: 30),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  finishedArea() {
    var areas = numbers[selectedPaintIndex]['area'] as List;
    var fillList = fillArea[selectedPaintIndex];
    var fill = fillList.join('');
    var all = areas.join('');
    if (fillList.indexOf(areas.first) > 0) {
      fill = fillList.reversed.join('');
    }
    if (all == fill) {
      if (!finishedNumber[selectedPaintIndex]) {
        setState(() {
          finishedNumber[selectedPaintIndex] = true;
        });
      }
    }

    if (finishedNumber.length == numbers.length) {
      var finishedAll =
          finishedNumber.entries.where((element) => !element.value).toList();
      if (finishedAll.length == 0) {
        setState(() {
          isFinishedAll = true;
          selectedPaintIndex = -1;
        });
      }
    }

    if (fillArea[selectedPaintIndex] != null &&
        fillArea[selectedPaintIndex].length <= 1) {
      setState(() {
        fillArea[selectedPaintIndex].clear();
      });
    }
  }

  bool isAddArea(String area) {
    if (finishedNumber.isNotEmpty) {
      var finishArea = finishedNumber.keys.map((e) {
        return finishedNumber[e] ? numbers[e]['area'] : [];
      }).reduce((value, element) => value + element) as List;

      if (finishArea.contains(area)) return false;
    }

    if (fillArea[selectedPaintIndex].length == 0) return true;

    var fills = fillArea.values.join('');
    if (fills.contains(area)) return false;

    var textLast = textAreas[selectedPaintIndex];
    if (fillArea[selectedPaintIndex].indexOf(textLast.first) >= 0 &&
        fillArea[selectedPaintIndex].indexOf(textLast.last) >= 0) {
      return false;
    }

    var x = area.split('/')[0];
    var y = area.split('/')[1];

    var last = fillArea[selectedPaintIndex].last;
    var x1 = last.split('/')[0];
    var y1 = last.split('/')[1];

    if (((double.parse(x) - double.parse(x1)).abs() > 1) ||
        (double.parse(y) - double.parse(y1)).abs() > 1) return false;

    return last.startsWith(x) || last.endsWith(y);
  }

  addFillArea(Offset location) {
    if (!fillArea.containsKey(selectedPaintIndex)) {
      fillArea[selectedPaintIndex] = [];
    }
    var target = getTargetArea(location);

    var textFill = textAreas.entries
        .where((element) => element.key != selectedPaintIndex)
        .map((e) => e.value)
        .reduce((value, element) => value + element)
        .toList();

    if (textFill.contains(target)) return;

    if (!fillArea[selectedPaintIndex].contains(target)) {
      if (isAddArea(target)) {
        setState(() {
          fillArea[selectedPaintIndex].add(target);
        });
      }
    } else {
      var index = fillArea[selectedPaintIndex].lastIndexOf(target);
      setState(() {
        fillArea[selectedPaintIndex] =
            fillArea[selectedPaintIndex].sublist(0, index + 1);
      });
    }
    print('fillArea: $fillArea');
  }

  chooseStartArea(Offset location) {
    var target = getTargetArea(location);
    numbers.asMap().entries.forEach((element) {
      var areas = element.value['area'] as List;

      if (target == areas.first || target == areas.last) {
        if (!element.value.containsKey(element.key)) {
          finishedNumber[element.key] = false;
        }
        if (finishedNumber[element.key]) {
          setState(() {
            selectedPaintIndex = -1;
          });
          return;
        }
        fillArea[element.key]?.clear();
        setState(() {
          selectedPaintIndex = element.key;
        });
      }
    });
  }

  String getTargetArea(Offset location) {
    final lineWidth = boxWidth / lines;
    var x = (location.dx / lineWidth).floor();
    var y = (location.dy / lineWidth).floor();
    return '$x/$y';
  }
}

class BasePainter extends CustomPainter {
  final List<dynamic> numbers;
  final int lines;

  BasePainter(this.numbers, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (numbers.isNotEmpty) {
      numbers.forEach((num) {
        final textSpan1 = TextSpan(
          text: num['text'],
          style: TextStyle(color: Color(int.parse(num['color'])), fontSize: 30),
        );
        var areas = num['area'] as List;
        var start = formatCoordinate(areas.first, size);
        TextPainter(text: textSpan1, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: 100)
          ..paint(canvas, Offset(start.dx - 11, start.dy - 15));

        var end = formatCoordinate(areas.last, size);
        TextPainter(text: textSpan1, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: 100)
          ..paint(canvas, Offset(end.dx - 11, end.dy - 15));
      });
    }
  }

  Offset formatCoordinate(String element, Size size) {
    var x = (double.parse(element.split('/')[0]) + 0.5) * (size.width / lines);
    var y = (double.parse(element.split('/')[1]) + 0.5) * (size.width / lines);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class MyPainter extends CustomPainter {
  final List<dynamic> numbers;
  final Map<int, List<String>> fillArea;
  final int lines;
  final int selectedIndex;

  MyPainter(this.numbers, this.fillArea, this.lines, this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final lineWidth = size.width / lines;
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    if (numbers.isNotEmpty && fillArea.isNotEmpty) {
      var fill = fillArea?.values
          ?.reduce((value, element) => value + element)
          ?.toList();
      numbers.forEach((element) {
        var areas = element['area'] as List;
        areas.forEach((area) {
          var x = double.parse(area.split('/')[0]);
          var y = double.parse(area.split('/')[1]);

          var cX = (x + 0.5) * lineWidth;
          var cY = (y + 0.5) * lineWidth;

          paint
            ..color = fill.contains(area)
                ? Colors.transparent
                : Color.fromARGB(220, 0, 0, 0);
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(cX, cY),
                  width: lineWidth - 1,
                  height: lineWidth - 1),
              paint);
        });
      });
    }
  }

  Offset formatCoordinate(String element, Size size) {
    var x = (double.parse(element.split('/')[0]) + 0.5) * (size.width / lines);
    var y = (double.parse(element.split('/')[1]) + 0.5) * (size.width / lines);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
