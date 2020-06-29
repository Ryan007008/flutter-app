import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/page/home.dart';
import 'package:flutterapp/page/mywork/setting.dart';
import 'package:flutterapp/page/paint/painting.dart';

void main() {
  runApp(MyApp());
//  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColoringFun Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFFD6F6F),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => HomePage(),
        '/setting': (BuildContext context) => SettingPage(),
      },
    );
  }
}

