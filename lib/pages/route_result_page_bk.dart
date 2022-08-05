import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/expansion_tile_widget.dart';
import '../utils/keep_alive_wrapper.dart';
import '../utils/log_utils.dart';

class RouteResultPage extends StatefulWidget {
  final Map<String, dynamic> routeResult;
  final String plan;
  final String city;
  RouteResultPage(this.routeResult, this.plan, this.city, {Key? key})
      : super(key: key);

  @override
  State<RouteResultPage> createState() =>
      _RouteResultPageState(routeResult, plan, city);
}

class _RouteResultPageState extends State<RouteResultPage>
    with TickerProviderStateMixin {
  Map<String, dynamic> routeResult = {};
  String plan = "";
  String city = "";
  _RouteResultPageState(this.routeResult, this.plan, this.city);

  late Map<String, dynamic> buslist;
  late List<dynamic> segmentlist;
  late String expensetime;
  late String expense;
  late int transitTimes;
  late int totalStations;
  List<Widget> arrow_icon_list = [];
  TextStyle bigTextStyle = TextStyle(fontSize: 40);
  TextStyle smallTextStyle = TextStyle(fontSize: 20);
  late TextStyle luxian_style;
  late TextStyle ditu_style;
  late TabController tabBarViewController;
  late PageController pageViewController;
  late PageController pageController;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    tabBarViewController = TabController(length: 2, vsync: this);
    pageViewController = PageController();
    pageController = PageController();
    luxian_style = bigTextStyle;
    ditu_style = smallTextStyle;
    buslist = routeResult["buslist"][0];
    segmentlist = buslist["segmentlist"];
    expensetime = buslist["expensetime"]; // 全程花费的时间
    transitTimes = segmentlist.length - 1; // 中转次数
    totalStations = 0; // 全程经过的站点总数
    expense = buslist["expense"]; // 全程票价
    if (expense.endsWith(".0")) {
      expense = expense.substring(0, expense.length - 2);
    }
    for (var i = 0; i < segmentlist.length; i++) {
      arrow_icon_list.add(Icon(Icons.keyboard_arrow_down));
      LogUtils.e(
          segmentlist[i]["bus_key_name"].toString().split("号")[0].substring(2));
      LogUtils.e((int.parse(segmentlist[i]["passdepotcount"].toString()) + 1)
          .toString());
      totalStations +=
          int.parse(segmentlist[i]["passdepotcount"].toString()) + 1;
    }
    LogUtils.e(totalStations.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            //欢迎文字
            Container(
              margin: EdgeInsets.only(top: 50, left: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    // hoverColor: Colors.transparent,
                    // focusColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        if (luxian_style == smallTextStyle) {
                          luxian_style = bigTextStyle;
                          ditu_style = smallTextStyle;
                          tabBarViewController.animateTo(0,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.ease);
                        }
                      });
                    },
                    child: Container(
                      height: 60,
                      width: 100,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "路线",
                        style: luxian_style,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    // hoverColor: Colors.transparent,
                    // focusColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        if (ditu_style == smallTextStyle) {
                          luxian_style = smallTextStyle;
                          ditu_style = bigTextStyle;
                          tabBarViewController.animateTo(1,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.ease);
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      height: 60,
                      width: 100,
                      child: Text(
                        "地图",
                        style: ditu_style,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 地铁图
            Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  // allowImplicitScrolling: true,
                  controller: tabBarViewController,
                  children: [
                    // 路线模式
                    Column(
                      children: [
                        // 全程站点总数和时长
                        Container(
                          margin: EdgeInsets.only(left: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 40),
                                child: Column(
                                  children: [
                                    Text(
                                      totalStations.toString(),
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
                                      (int.parse(expensetime) ~/ 60 + 1)
                                          .toString(),
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
                        ),
                        // 途径站点的详细信息
                        Container(
                          child: Expanded(
                            child: ListView.builder(
                                padding: EdgeInsets.only(left: 25),
                                itemCount: (transitTimes) * 3 + 4,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    String hexColorString =
                                        segmentlist[index ~/ 3]["color"]
                                            .toString();
                                    if (hexColorString.length == 6) {
                                      hexColorString = "0xFF" + hexColorString;
                                    }
                                    return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 实现左侧颜色条效果，顶部半圆矩形块
                                          Container(
                                            width: 20,
                                            height: 30,
                                            child: Stack(
                                              alignment: Alignment.topCenter,
                                              children: [
                                                // 第一层，矩形
                                                Positioned(
                                                    top: 15,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(int.parse(
                                                            hexColorString)),
                                                        border: Border(
                                                            top: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString))),
                                                            bottom: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString)))),
                                                      ),
                                                      width: 20,
                                                      height: 15,
                                                    )),
                                                // 第二层，圆形
                                                Positioned(
                                                  top: 5,
                                                  child: CircleAvatar(
                                                    backgroundColor: Color(
                                                        int.parse(
                                                            hexColorString)),
                                                    radius: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          // 站点名称
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              segmentlist[index ~/ 3]
                                                  ["startname"],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          )
                                        ]);
                                  } else if (index % 3 == 1) {
                                    String lineID = segmentlist[index ~/ 3]
                                            ["bus_key_name"]
                                        .toString()
                                        .split("号")[0]
                                        .substring(2);
                                    String hexColorString =
                                        segmentlist[index ~/ 3]["color"]
                                            .toString();
                                    if (hexColorString.length == 6) {
                                      hexColorString = "0xFF" + hexColorString;
                                    }
                                    return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // 实现左侧颜色条效果，矩形块
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Color(
                                                  int.parse(hexColorString)),
                                              border: Border(
                                                  top: BorderSide(
                                                      width: 0,
                                                      color: Color(int.parse(
                                                          hexColorString))),
                                                  bottom: BorderSide(
                                                      width: 0,
                                                      color: Color(int.parse(
                                                          hexColorString)))),
                                            ),
                                            width: 20,
                                            height: 30,
                                          ),
                                          // 线路标识，圆形
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: CircleAvatar(
                                              backgroundColor: Color(
                                                  int.parse(hexColorString)),
                                              radius: 12,
                                              child: Text(
                                                lineID,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          // 站点名称
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "往 ${segmentlist[index ~/ 3]["directionName"]} 方向",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                        ]);
                                  } else if (index % 3 == 2) {
                                    List<String> passdepotname =
                                        segmentlist[index ~/ 3]["passdepotname"]
                                            .toString()
                                            .split(" ");
                                    String passdepotcount = (int.parse(
                                                segmentlist[index ~/ 3]
                                                    ["passdepotcount"]) +
                                            1)
                                        .toString();
                                    String drivertime = ((int.parse(
                                                        segmentlist[index ~/ 3]
                                                            ["drivertime"]) +
                                                    int.parse(
                                                        segmentlist[index ~/ 3]
                                                            ["foottime"])) ~/
                                                60 +
                                            1)
                                        .toString();
                                    String hexColorString =
                                        segmentlist[index ~/ 3]["color"]
                                            .toString();
                                    if (hexColorString.length == 6) {
                                      hexColorString = "0xFF" + hexColorString;
                                    }
                                    return UserExpansionTile(
                                      initiallyExpanded: false,
                                      onExpansionChanged: (bool isExpanded) {
                                        LogUtils.e(isExpanded.toString());
                                        if (isExpanded) {
                                          setState(() {
                                            arrow_icon_list[index ~/ 3] =
                                                Icon(Icons.keyboard_arrow_up);
                                          });
                                        } else {
                                          setState(() {
                                            arrow_icon_list[index ~/ 3] =
                                                Icon(Icons.keyboard_arrow_down);
                                          });
                                        }
                                      },
                                      // tilePadding: EdgeInsets.zero,
                                      dividerColor: Colors.transparent,
                                      title: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // 实现左侧颜色条效果，矩形块
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(
                                                    int.parse(hexColorString)),
                                                border: Border(
                                                    top: BorderSide(
                                                        width: 0,
                                                        color: Color(int.parse(
                                                            hexColorString))),
                                                    bottom: BorderSide(
                                                        width: 0,
                                                        color: Color(int.parse(
                                                            hexColorString)))),
                                              ),
                                              width: 20,
                                              height: 30,
                                            ),
                                            // 乘坐几站，用时多少
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Row(
                                                children: [
                                                  arrow_icon_list[index ~/ 3],
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      "乘坐${passdepotcount}站 （约${drivertime}分钟）",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]),
                                      children: [
                                        ListView.builder(
                                            itemCount: int.parse(
                                                segmentlist[index ~/ 3]
                                                    ["passdepotcount"]),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (BuildContext context, int id) {
                                              return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // 实现左侧颜色条效果，矩形块
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(int.parse(
                                                            hexColorString)),
                                                        border: Border(
                                                            top: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString))),
                                                            bottom: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString)))),
                                                      ),
                                                      width: 20,
                                                      height: 30,
                                                    ),
                                                    // 站点名
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 15),
                                                      child: Text(
                                                        "${passdepotname[id]}",
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ]);
                                            })
                                      ],
                                    );
                                  } else if (index % 3 == 0 &&
                                      index != 0 &&
                                      index != (transitTimes) * 3 + 3) {
                                    String hexColorString_pre =
                                        segmentlist[index ~/ 3 - 1]["color"]
                                            .toString();
                                    if (hexColorString_pre.length == 6) {
                                      hexColorString_pre =
                                          "0xFF" + hexColorString_pre;
                                    }
                                    String hexColorString_after =
                                        segmentlist[index ~/ 3]["color"]
                                            .toString();
                                    if (hexColorString_after.length == 6) {
                                      hexColorString_after =
                                          "0xFF" + hexColorString_after;
                                    }
                                    return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // 实现左侧颜色条效果，颜色切换处
                                          Column(
                                            children: [
                                              // 上半，矩形 + 底部圆形
                                              Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(int.parse(
                                                          hexColorString_pre)),
                                                      border: Border(
                                                          top: BorderSide(
                                                              width: 0,
                                                              color: Color(
                                                                  int.parse(
                                                                      hexColorString_pre))),
                                                          bottom: BorderSide(
                                                              width: 0,
                                                              color: Color(
                                                                  int.parse(
                                                                      hexColorString_pre)))),
                                                    ),
                                                    width: 20,
                                                    height: 10,
                                                  ),
                                                  CircleAvatar(
                                                    backgroundColor: Color(
                                                        int.parse(
                                                            hexColorString_pre)),
                                                    radius: 10,
                                                  ),
                                                ],
                                              ),
                                              // 下半，矩形 + 顶部圆形
                                              Stack(
                                                children: [
                                                  Positioned(
                                                    top: 10,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(int.parse(
                                                            hexColorString_after)),
                                                        border: Border(
                                                            top: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString_after))),
                                                            bottom: BorderSide(
                                                                width: 0,
                                                                color: Color(
                                                                    int.parse(
                                                                        hexColorString_after)))),
                                                      ),
                                                      width: 20,
                                                      height: 10,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    backgroundColor: Color(
                                                        int.parse(
                                                            hexColorString_after)),
                                                    radius: 10,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // 站点名称
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              segmentlist[index ~/ 3]
                                                  ["startname"],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          )
                                        ]);
                                  } else if (index == (transitTimes) * 3 + 3) {
                                    String hexColorString =
                                        segmentlist[index ~/ 3 - 1]["color"]
                                            .toString();
                                    if (hexColorString.length == 6) {
                                      hexColorString = "0xFF" + hexColorString;
                                    }
                                    return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // 实现左侧颜色条效果，底部半圆矩形块
                                          Container(
                                            width: 20,
                                            height: 30,
                                            child: Stack(
                                              alignment: Alignment.topCenter,
                                              children: [
                                                // 第一层，矩形
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(int.parse(
                                                        hexColorString)),
                                                    border: Border(
                                                        top: BorderSide(
                                                            width: 0,
                                                            color: Color(int.parse(
                                                                hexColorString))),
                                                        bottom: BorderSide(
                                                            width: 0,
                                                            color: Color(int.parse(
                                                                hexColorString)))),
                                                  ),
                                                  width: 20,
                                                  height: 15,
                                                ),
                                                // 第二层，圆形
                                                Positioned(
                                                  top: 5,
                                                  child: CircleAvatar(
                                                    backgroundColor: Color(
                                                        int.parse(
                                                            hexColorString)),
                                                    radius: 10,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          // 站点名称
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              segmentlist[index ~/ 3 - 1]
                                                  ["endname"],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          )
                                        ]);
                                  }
                                  return Container();
                                }),
                          ),
                        )
                      ],
                    ),
                    KeepAliveWrapper(
                      child: PageView(
                        allowImplicitScrolling: true,
                        children: [
                          WebView(
                            initialUrl:
                                "http://0.0.0.0:9998/files/html/subway_map_route_result.html",
                            javascriptMode: JavascriptMode.unrestricted,
                            javascriptChannels: {
                              JavascriptChannel(
                                  name: "subwayCompleteCallFlutter",
                                  onMessageReceived: (msg) {
                                    print(msg.message);
                                    if (msg.message ==
                                        "subwayCompleteSuccess") {
                                      _webViewController
                                          ?.runJavascript("route()");
                                    }
                                  }),
                            },
                            onWebViewCreated:
                                (WebViewController webViewController) {
                              _webViewController = webViewController;
                            },
                            onPageFinished: (url) {
                              _webViewController?.runJavascript(
                                  "initMap('$city', '${buslist["spoi"]["name"]}', '${buslist["epoi"]["name"]}')");
                            },
                          )
                        ],
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void setStartStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      var station_info = jsonDecode(value);
      station_info = jsonDecode(station_info);
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      _webViewController?.runJavascript("setStartStation('$station_id')");
    });
    // _webViewController?.runJavascript("deleteMysubway()");
    // _webViewController?.runJavascript("createMap('南京市')");
  }

  void setEndStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      var station_info = jsonDecode(value);
      station_info = jsonDecode(station_info);
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      _webViewController?.runJavascript("setEndStation('$station_id')");
    });
  }
}
