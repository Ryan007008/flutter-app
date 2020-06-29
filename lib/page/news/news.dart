import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

const NEWS_CELL_RATIO = 140 / 334;

class NewsPage extends StatefulWidget {
  const NewsPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NewsPageState();
  }
}

class NewsPageState extends State<NewsPage> with AutomaticKeepAliveClientMixin {
  List data;
  bool loading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = [];
    loading = true;
    getData();
  }

  getData() async {
    var url = 'https://d18z1pzpcvd03w.cloudfront.net/actives.json';
    var httpClient = new HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        var p = jsonDecode(json);
        setState(() {
          data = p['data'].sublist(0, 10);
          loading = false;
        });
      }
    } catch (e) {}
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
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var width = MediaQuery.of(context).size.width;
          return GestureDetector(
              onTap: () => launch(data[index]['link'],
                  enableJavaScript: true, forceWebView: false),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Container(
                      child: ClipRRect(
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                "https://d18z1pzpcvd03w.cloudfront.net/${data[index]['icon']}",
                            placeholder: (context, url) => SpinKitCircle(
                                  color: Color(0xFFFD6F6F),
                                )),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      width: width * NEWS_CELL_RATIO,
                      height: width * NEWS_CELL_RATIO,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        height: width * NEWS_CELL_RATIO,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[index]['title'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(data[index]['sub_title'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Color(0xFF999999),
                                        fontSize: 14)),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 80,
                                  height: 27,
//                              color: Colors.red,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFF7F7F),
                                      borderRadius:
                                          BorderRadius.circular(13.5)),
                                  child: Center(
                                    child: Text(
                                      data[index]['button_title'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
