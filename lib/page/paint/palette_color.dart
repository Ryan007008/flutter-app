import 'package:flutter/material.dart';

class PaletteColor extends StatelessWidget {
  final List<String> paletteColors;
  final Map<String, dynamic> colorGroup;
  final Map<String, Set<String>> fillColors;
  final selected;
  final Function(int index, String color) onTap;

  PaletteColor(this.paletteColors, this.colorGroup, this.fillColors,
      this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: paletteColors.length,
          itemBuilder: (context, index) {
            var color = paletteColors[index];
            var allIds = (colorGroup[color] as List).length.toDouble();
            var finishedIds = fillColors[color]?.length?.toDouble();
            var progress = (finishedIds ?? 0.0) / allIds;
            return GestureDetector(
              onTap: () {
                onTap(index, color);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  progress != 1.0 ? SizedBox(
                    width: selected == index ? 55 : 40,
                    height: selected == index ? 55 : 40,
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xFFCCCCCC),
                      valueColor: AlwaysStoppedAnimation(Color(0xFF0AE682)),
                      value: progress,
                      strokeWidth: 5,
                    ),
                  ) : Container(),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: getBoxDecoration(paletteColors[index]),
                    width: 50.0,
                    height: 50.0,
                    child: Center(
                      child: Text('${index + 1}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: selected == index ? 26 : 20)),
                    ),
                  )
                ],
              ),
            );
          }),
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

  LinearGradient getLinearGradient(
      String value, Alignment begin, Alignment end) {
    var colorType = value.substring(0, 1);
    var colors = value.substring(2).split(',');
    var colorStart = colors[0];
    var colorEnd = colors[1];
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
    return RadialGradient(colors: [
      Color(int.parse('0xFF${colorStart.substring(1)}')),
      Color(int.parse('0xFF${colorEnd.substring(1)}')),
    ]);
  }
}
