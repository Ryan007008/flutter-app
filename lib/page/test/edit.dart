import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CustomEdit extends StatefulWidget {
  final int localIndex;

  CustomEdit(this.localIndex);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomEditState();
  }
}

class CustomEditState extends State<CustomEdit> {
  Map<int, List<String>> fillArea = LinkedHashMap();
  int lines = 5;
  int selectedIndex = 0;
  List<MaterialColor> colors = [
    Colors.red,
    Colors.brown,
    Colors.blue,
    Colors.deepPurple,
    Colors.green,
    Colors.pink,
    Colors.amber,
    Colors.cyan
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('编辑关卡'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 50,
            child: TextField(
              maxLines: 1,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: '创建表格数',
              ),
              onChanged: (value) {
                setState(() {
                  lines = int.parse(value);
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50.0),
            child: Center(
              child: GestureDetector(
                onPanStart: (d) {
                  chooseStartArea(d.localPosition);
                },
                onPanUpdate: (d) {
                  if (d.localPosition.dx < 0 ||
                      d.localPosition.dy < 0 ||
                      d.localPosition.dx > 300 ||
                      d.localPosition.dy > 300) return;
                  addFillArea(d.localPosition);
                },
                onPanEnd: (d) {
                  finishedArea();
                  setState(() {
                    selectedIndex = -1;
                  });
                },
                child: CustomPaint(
                  size: Size(300, 300),
                  painter: BasePainter(fillArea, selectedIndex, lines, colors),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => generate(),
            child: Container(
              width: 200,
              height: 50,
              margin: const EdgeInsets.only(top: 50.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.red, width: 2.0)),
              child: Center(
                child: Text(
                  '生成关卡',
                  style: TextStyle(color: Colors.red, fontSize: 30.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  generate() async {
    if (fillArea.length > 0) {
      var all =
          fillArea.values.reduce((value, element) => value + element).toList();
      if (all.length == lines * lines) {
        Directory directory = await getExternalStorageDirectory();
        Directory createData = Directory('${directory.path}/createData');
        if (!createData.existsSync()) {
          createData.createSync();
        }
        var num = createData.listSync().length;
        var file = File('${createData.path}/testData${num + widget.localIndex}_$lines.json');
        if (file.existsSync()) {
          file.deleteSync();
        }
        file.createSync();
        var contents = '{\n' +
            '  "lines": $lines,\n' +
            '  "number": [\n' +
            getAreaString() +
            '  ]' +
            '}';
        file.writeAsStringSync(contents);
        setState(() {
          selectedIndex = 0;
          fillArea?.clear();
        });
      }
    }
  }

  String getAreaString() {
    var all = '';
    fillArea.entries.forEach((element) {
      all = all +
          '    {\n' +
          '      "text": "${element.key + 1}",\n' +
          '      "color": "${colors[element.key].value}",\n' +
          '      "area": ' +
          element.value.map((e) => '"$e"').toList().toString() +
          ((element.key == fillArea.length - 1) ? '\n    }\n' : '\n    },\n');
    });
    return all;
  }

  finishedArea() {
    var a = fillArea[selectedIndex];
    if (a.length <= 2) {
      fillArea[selectedIndex]?.clear();
    }
  }

  addFillArea(Offset location) {
    var target = getTargetArea(location);
    if (fillArea[selectedIndex].contains(target)) {
      return;
    }

    var allFillArea = fillArea.entries
        .map((e) => e.value)
        .reduce((value, element) => value + element)
        .toList();

    if (allFillArea.contains(target)) return;

    setState(() {
      fillArea[selectedIndex].add(target);
    });
    print('fillArea: $fillArea');
  }

  chooseStartArea(Offset location) {
    var a = fillArea.entries.where((element) => element.value.length > 0).toList().length;
    if (a > lines) return;
    if (!fillArea.containsKey(a)) {
      fillArea.putIfAbsent(a, () => []);
    }
    setState(() {
      selectedIndex = a;
    });
  }

  String getTargetArea(Offset location) {
    final lineWidth = 300 / lines;
    var x = (location.dx / lineWidth).floor();
    var y = (location.dy / lineWidth).floor();
    return '$x/$y';
  }
}

class BasePainter extends CustomPainter {
  final Map<int, List<String>> fillArea;
  final int lines;
  final int selectedIndex;
  final List<MaterialColor> colors;

  BasePainter(this.fillArea, this.selectedIndex, this.lines, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var paint = Paint()..isAntiAlias = true;

    if (lines > 0) {
      paint
        ..strokeWidth = 1.0
        ..color = Colors.black
        ..style = PaintingStyle.stroke;
      final lineWidth = size.width / lines;
      for (var i = 0; i <= lines; i++) {
        canvas.drawLine(
            Offset(lineWidth * i, 0), Offset(lineWidth * i, size.width), paint);
        canvas.drawLine(
            Offset(0, lineWidth * i), Offset(size.width, lineWidth * i), paint);
      }
    }
    if (fillArea.length > 0) {
      fillArea.entries.forEach((element) {
        if (element.value.length > 0) {
          paint
            ..strokeWidth = size.width / lines / 3
            ..strokeCap = StrokeCap.round
            ..color = Colors.black26;
          var offsets =
              element.value.map((e) => formatCoordinate(e, size)).toList();
          var path = Path()..addPolygon(offsets, false);
          canvas.drawPath(path, paint);

          final textSpan = TextSpan(
            text: element.key.toString(),
            style: TextStyle(color: colors[element.key], fontSize: 30),
          );
          var start = offsets.first;
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..layout(minWidth: 0, maxWidth: 100)
            ..paint(canvas, Offset(start.dx - 11, start.dy - 15));

          var end = offsets.last;
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..layout(minWidth: 0, maxWidth: 100)
            ..paint(canvas, Offset(end.dx - 11, end.dy - 15));
        }
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
