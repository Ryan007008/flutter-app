import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingPage extends StatefulWidget {
  const SettingPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  List<List<dynamic>> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = [
      [
        {
          'text': 'Subscription',
          'icon': 'images/ic_set_subscri.png',
          'default': false,
          'isOpen': false
        },
        {
          'text': 'Restore',
          'icon': 'images/ic_set_restore.png',
          'default': false,
          'isOpen': false
        },
      ],
      [
        {
          'text': 'Vibration',
          'icon': 'images/ic_set_vibra_on.png',
          'default': true,
          'isOpen': true
        },
        {
          'text': 'Hide colored',
          'icon': 'images/ic_set_conceal_on.png',
          'default': true,
          'isOpen': true
        },
        {
          'text': 'Add effects',
          'icon': 'images/ic_set_filter.png',
          'default': true,
          'isOpen': true
        },
      ],
      [
        {
          'text': 'Rate this app',
          'icon': 'images/ic_set_rate.png',
          'default': false,
          'isOpen': false
        },
        {
          'text': 'Facebook',
          'icon': 'images/ic_set_fb.png',
          'default': false,
          'isOpen': false
        },
      ],
      [
        {
          'text': 'Dark mode',
          'icon': 'images/ic_set_moon.png',
          'default': true,
          'isOpen': true
        },
        {
          'text': 'Wonderland',
          'icon': 'images/ic_set_alice.png',
          'default': false,
          'isOpen': false
        },
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Color(0x22000008),
                    offset: Offset(0.0, 1.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0)
              ]),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      child:
                          Icon(Icons.arrow_back_ios, color: Color(0xFF999999)),
                      width: 48,
                      height: 48,
                    ),
                  ),
                  Container(
                    child: Text('设置',
                        style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                    alignment: Alignment.center,
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: getList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getList() {
    return data.map((e) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.only(bottom: 28.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0), color: Colors.white),
        child: Column(
          children: getListItem(e),
        ),
      );
    }).toList();
  }

  List<Widget> getListItem(List<dynamic> data) {
    return data.map((e) {
      return Container(
          height: 54,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(e['icon']),
              ),
              Expanded(
                child: Text(
                  e['text'],
                  style: TextStyle(fontSize: 21, color: Color(0xFF333333)),
                ),
              ),
              e['default']
                  ? Switch(
                      value: e['isOpen'],
                      onChanged: (value) {},
                      activeColor: Color(0xFF68cd67),
                    )
                  : Container(
                      child: null,
                    )
            ],
          ));
    }).toList();
  }
}
