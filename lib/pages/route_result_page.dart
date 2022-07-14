import 'package:flutter/material.dart';

class RouteResultPage extends StatefulWidget {
  final Map<String, dynamic> routeResult;
  RouteResultPage(this.routeResult, {Key? key}) : super(key: key);

  @override
  State<RouteResultPage> createState() => _RouteResultPageState(routeResult);
}

class _RouteResultPageState extends State<RouteResultPage> {
  Map<String, dynamic> routeResult = {};
  _RouteResultPageState(this.routeResult);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            color: Colors.grey[600],
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          "查询结果",
          style: TextStyle(color: Colors.grey[800], fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
        child: Column(
          children: [
            //欢迎文字
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Text(
                    "路线",
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.left,
                  ),
                ),
                Text(
                  "地图",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      Text(
                        "10",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "站",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      Text(
                        "33",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "分",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
