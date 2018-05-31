import 'dart:async';

import 'package:daily/bean/tcitem.dart';
import 'package:daily/ui/photoppt.dart';
import 'package:daily/ui/photolist.dart';
import 'package:daily/utils/net/tcSev/TCApi.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '每日图文',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  var items = Map<int, List<TCItem>>();

  @override
  void initState() {
    super.initState();

    _getNews(0, null);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("热门图片"),
          centerTitle: true,
        ),
        body: new RefreshIndicator(
          onRefresh: () {
            return _getNews(0, null);
          },
          child: new GridView.count(
            physics: AlwaysScrollableScrollPhysics(),
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this would produce 2 rows.
            crossAxisCount: 1,
            // Generate 100 Widgets that display their index in the List
            children: List.generate(count, (index) {
              return GestureDetector(
                  onTap: () {
                    _next(index);
                  },
                  child: Hero(
                    tag: "tag-" + index.toString() + "-0",
                    child: Container(
                        margin: const EdgeInsets.all(2.0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            new CachedNetworkImage(
                              imageUrl: items[index][0].url,
                              placeholder: Container(
                                child: Image.asset("assets/ic-pic-loading.png"),
                              ),
                              fit: BoxFit.cover,
                              errorWidget: new Icon(Icons.error),
                            ),
                            Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: new BoxDecoration(
                                  color: Colors.black45,
                                ),
                                child: Center(
                                  child: Text(
                                    items[index][0].title.length != 0
                                        ? items[index][0].title
                                        : items[index][0].content,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ],
                        )),
                  ));
            }),
          ),
        ));
  }

  Future<Null> _getNews(page, postId) async {
    if (page == 0) {
      setState(() {
        this.items.clear();
        this.count = 0;
      });
    }
    TCApi().getNew(page, postId, _getNewSuccess, _getNewFail);
    return null;
  }

  void _getNewSuccess(data) {
    var map = Map<int, List<TCItem>>();
    int count = this.count;
    for (var d in data["feedList"]) {
      if (d != []) {
        var items = <TCItem>[];
        for (var img in d["images"]) {
          if (img != null) {
            String url = "https://photo.tuchong.com/" + d["author_id"].toString()
                + "/f/" + img["img_id"].toString() + ".jpg";

            items.add(TCItem(d["title"], d["content"], url));
          }
        }
        if (items.length > 0) {
          map.putIfAbsent(count, () => items);
          count++;
        }
      }
    }

    setState(() {
      this.items.addAll(map);
      this.count = count;
    });
  }

  void _getNewFail(data) {
    print(data);
  }

  void _next(index) {
    if (items[index].length > 1) {
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
        return new PhotoList(items[index], index);
      }));
    } else {
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
        return new PhotoPPT(items[index], index, 0);
      }));
    }
  }
}