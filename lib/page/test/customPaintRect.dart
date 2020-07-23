import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomRouteRect extends StatefulWidget {
  final name;
  final fileName;

  CustomRouteRect(this.name, this.fileName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomRouteRectState();
  }
}

class CustomRouteRectState extends State<CustomRouteRect> {
  Map<int, bool> finishedNumber = LinkedHashMap();
  List<dynamic> numbers = [];
  int lines = 0;
  double boxWidth;
  int selectedPaintIndex = -1;
  bool loading = true;
  Map<int, List<String>> fillArea = LinkedHashMap();
  Map<int, List<String>> textAreas = LinkedHashMap();
  bool isFinishedAll = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    boxWidth =
        (window.physicalSize.width / window.devicePixelRatio).floor() - 20.0;
    DefaultAssetBundle.of(context)
        .loadString('data/${widget.fileName}.json')
        .then((value) {
      var json = jsonDecode(value);
      setState(() {
        numbers = json['number'] as List;
        numbers.asMap().entries.forEach((element) {
          var areas = element.value['area'] as List;
          textAreas.putIfAbsent(element.key, () => [areas.first, areas.last]);
        });
        lines = json['lines'];
        loading = false;
      });
    });
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
        title: Text(widget.name),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                  size: Size(boxWidth, boxWidth),
                  painter: BasePainter(numbers, finishedNumber, lines)),
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
                },
                child: CustomPaint(
                  size: Size(boxWidth, boxWidth),
                  painter: MyPainter(numbers, finishedNumber, lines,
                      selectedPaintIndex, fillArea),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isAddArea(String area) {
    if (finishedNumber.isNotEmpty) {
      var finishArea = finishedNumber.keys.map((e) {
        return finishedNumber[e] ? numbers[e]['area'] : [];
      }).reduce((value, element) => value + element) as List;

      if (finishArea.contains(area)) return false;
    }

    if (fillArea[selectedPaintIndex].length == 0) return true;

    var last = fillArea[selectedPaintIndex].last;

    if (last == area) return false;

    var x = area.split('/')[0];
    var y = area.split('/')[1];

    var x1 = last.split('/')[0];
    var y1 = last.split('/')[1];

    if (((double.parse(x) - double.parse(x1)).abs() > 1) ||
        (double.parse(y) - double.parse(y1)).abs() > 1) return false;

    return last.startsWith(x) || last.endsWith(y);
  }

  addFillArea(Offset p) {
    var lineWidth = boxWidth / lines;
    if (!fillArea.containsKey(selectedPaintIndex)) {
      fillArea[selectedPaintIndex] = [];
    }

    var x = (p.dx / lineWidth).floor();
    var y = (p.dy / lineWidth).floor();
    var area = '${x >= lines ? lines - 1 : x}/${y >= lines ? lines - 1 : y}';

    print('area: $area');

    var textFill = textAreas.entries
        .where((element) => element.key != selectedPaintIndex)
        .map((e) => e.value)
        .reduce((value, element) => value + element)
        .toList();

    if (textFill.contains(area)) return;

    if (!fillArea[selectedPaintIndex].contains(area)) {
      if (isAddArea(area)) {
        setState(() {
          fillArea[selectedPaintIndex].add(area);
        });
      }
    } else {
      var index = fillArea[selectedPaintIndex].lastIndexOf(area);
      setState(() {
        fillArea[selectedPaintIndex] =
            fillArea[selectedPaintIndex].sublist(0, index + 1);
      });
    }
    print('fillArea: $fillArea');
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
  }

  chooseStartArea(Offset location) {
    final lineWidth = boxWidth / lines;
    var x = (location.dx / lineWidth).floor();
    var y = (location.dy / lineWidth).floor();
    var target = '$x/$y';
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
}

class BasePainter extends CustomPainter {
  final List<dynamic> numbers;
  final Map<int, bool> finishedNumber;
  final int lines;

  BasePainter(this.numbers, this.finishedNumber, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..isAntiAlias = true;

    if (lines > 0) {
      paint
        ..strokeWidth = 1.0
        ..color = Color(0xFFd1ce2e)
        ..style = PaintingStyle.stroke;
      final lineWidth = size.width / lines;
      for (var i = 0; i <= lines; i++) {
        canvas.drawLine(
            Offset(lineWidth * i, 0), Offset(lineWidth * i, size.width), paint);
        canvas.drawLine(
            Offset(0, lineWidth * i), Offset(size.width, lineWidth * i), paint);
      }
    }

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
  final Map<int, bool> finishedNumber;
  final int lines;
  int selectedIndex;
  final Map<int, List<String>> fillArea;

  MyPainter(this.numbers, this.finishedNumber, this.lines, this.selectedIndex,
      this.fillArea);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final lineWidth = size.width / lines;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (finishedNumber.length > 0) {
      finishedNumber.entries.forEach((element) {
        var num = numbers[element.key];
        if (element.value) {
          paint
            ..strokeWidth = lineWidth / 3
            ..color = Color(int.parse(num['color']));
          var areas = num['area'] as List;
          var offsets = areas.map((e) => formatCoordinate(e, size)).toList();
          var path = Path()..addPolygon(offsets, false);
          canvas.drawPath(path, paint);
        }
      });
    }

    if (selectedIndex > -1) {
      var num = numbers[selectedIndex];
      var array = fillArea[selectedIndex];
      if (array.isNotEmpty) {
        paint
          ..style = PaintingStyle.fill
          ..color = Color(int.parse(num['color']));
        canvas.drawCircle(
            formatCoordinate(array.first, size), lineWidth / 4, paint);

        paint
          ..strokeWidth = lineWidth / 3
          ..style = PaintingStyle.stroke;

        var move = formatCoordinate(array[0], size);
        var path = Path()..moveTo(move.dx, move.dy);
        if (array.length > 1) {
          array.sublist(1).forEach((element) {
            var line = formatCoordinate(element, size);
            path.lineTo(line.dx, line.dy);
          });
          canvas.drawPath(path, paint);

          paint..style = PaintingStyle.fill;
          canvas.drawCircle(
              formatCoordinate(array.last, size), lineWidth / 4, paint);
        }
      }
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
