import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/expansion-tile-widget.dart';
import '../utils/keep-alive-wrapper.dart';
import '../utils/log-utils.dart';

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
  late List _webViewControllerList;

  @override
  void initState() {
    super.initState();
    tabBarViewController = TabController(length: 2, vsync: this);
    pageViewController = PageController(viewportFraction: 0.9999);
    pageController = PageController(viewportFraction: 0.9999);
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
    _webViewControllerList =
        List.filled(segmentlist.length + 2, _webViewController);
    // for (var i = 0; i < segmentlist.length + 2; i++) {
    //   _webViewControllerList.add(WebViewController());
    // }
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
    return WillPopScope(
      onWillPop: () async {
        pageViewController.jumpToPage(0);
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // 标题栏
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(color: Colors.grey),
              )),
              padding: EdgeInsets.only(top: 45),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: IconButton(
                    color: Colors.grey[600],
                    onPressed: () {
                      pageViewController.jumpToPage(0);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios_new)),
                title: Text(
                  "$plan方案详情",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[800], fontSize: 22),
                ),
                trailing: IconButton(
                    color: Colors.transparent,
                    onPressed: null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.transparent,
                    )),
              ),
            ),
            // 路线和地图选项卡
            Container(
              margin: EdgeInsets.only(top: 20, left: 35, right: 15),
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
                          pageViewController.animateToPage(0,
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
                          pageViewController.animateToPage(1,
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
            // 滑动页面
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
                child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageViewController,
                    children: [
                      // 路线模式
                      KeepAliveWrapper(
                        child: Column(
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        String hexColorString =
                                            segmentlist[index ~/ 3]["color"]
                                                .toString();
                                        if (hexColorString.length == 6) {
                                          hexColorString =
                                              "0xFF" + hexColorString;
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
                                                  alignment:
                                                      Alignment.topCenter,
                                                  children: [
                                                    // 第一层，矩形
                                                    Positioned(
                                                        top: 15,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
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
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  segmentlist[index ~/ 3]
                                                      ["startname"],
                                                  style:
                                                      TextStyle(fontSize: 20),
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
                                          hexColorString =
                                              "0xFF" + hexColorString;
                                        }
                                        return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // 实现左侧颜色条效果，矩形块
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
                                                height: 30,
                                              ),
                                              // 线路标识，圆形
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: CircleAvatar(
                                                  backgroundColor: Color(
                                                      int.parse(
                                                          hexColorString)),
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
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  "往 ${segmentlist[index ~/ 3]["directionName"]} 方向",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              )
                                            ]);
                                      } else if (index % 3 == 2) {
                                        List<String> passdepotname =
                                            segmentlist[index ~/ 3]
                                                    ["passdepotname"]
                                                .toString()
                                                .split(" ");
                                        String passdepotcount = (int.parse(
                                                    segmentlist[index ~/ 3]
                                                        ["passdepotcount"]) +
                                                1)
                                            .toString();
                                        String drivertime = ((int.parse(
                                                            segmentlist[
                                                                    index ~/ 3][
                                                                "drivertime"]) +
                                                        int.parse(segmentlist[
                                                                index ~/ 3]
                                                            ["foottime"])) ~/
                                                    60 +
                                                1)
                                            .toString();
                                        String hexColorString =
                                            segmentlist[index ~/ 3]["color"]
                                                .toString();
                                        if (hexColorString.length == 6) {
                                          hexColorString =
                                              "0xFF" + hexColorString;
                                        }
                                        return UserExpansionTile(
                                          initiallyExpanded: false,
                                          expandSpeed:
                                              Duration(milliseconds: 250),
                                          onExpansionChanged:
                                              (bool isExpanded) {
                                            LogUtils.e(isExpanded.toString());
                                            if (isExpanded) {
                                              setState(() {
                                                arrow_icon_list[index ~/ 3] =
                                                    Icon(Icons
                                                        .keyboard_arrow_up);
                                              });
                                            } else {
                                              setState(() {
                                                arrow_icon_list[index ~/ 3] =
                                                    Icon(Icons
                                                        .keyboard_arrow_down);
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
                                                  height: 30,
                                                ),
                                                // 乘坐几站，用时多少
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Row(
                                                    children: [
                                                      arrow_icon_list[
                                                          index ~/ 3],
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
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
                                            MediaQuery.removePadding(
                                              context: context,
                                              removeTop: true,
                                              child: ListView.builder(
                                                  itemCount: int.parse(
                                                      segmentlist[index ~/ 3]
                                                          ["passdepotcount"]),
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int id) {
                                                    return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // 实现左侧颜色条效果，矩形块
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  int.parse(
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
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 15),
                                                            child: Text(
                                                              "${passdepotname[id]}",
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ]);
                                                  }),
                                            )
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
                                                        decoration:
                                                            BoxDecoration(
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
                                                          decoration:
                                                              BoxDecoration(
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
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  segmentlist[index ~/ 3]
                                                      ["startname"],
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              )
                                            ]);
                                      } else if (index ==
                                          (transitTimes) * 3 + 3) {
                                        String hexColorString =
                                            segmentlist[index ~/ 3 - 1]["color"]
                                                .toString();
                                        if (hexColorString.length == 6) {
                                          hexColorString =
                                              "0xFF" + hexColorString;
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
                                                  alignment:
                                                      Alignment.topCenter,
                                                  children: [
                                                    // 第一层，矩形
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
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  segmentlist[index ~/ 3 - 1]
                                                      ["endname"],
                                                  style:
                                                      TextStyle(fontSize: 20),
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
                      ),
                      // 地图模式
                      KeepAliveWrapper(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.lightBlue)),
                          child: PageView.builder(
                              // allowImplicitScrolling: true,
                              physics: NeverScrollableScrollPhysics(),
                              // onPageChanged: (value) {
                              //   print(value);
                              //   if (value == 0) {
                              //     setStartStationOnMap(buslist["spoi"]["name"]);
                              //   }
                              // },
                              controller: pageController,
                              itemCount: transitTimes + 3,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return KeepAliveWrapper(
                                    child: Stack(children: [
                                      WebView(
                                        initialUrl:
                                            "http://0.0.0.0:9998/files/html/subway_map_route.html",
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                        javascriptChannels: {
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterRoute",
                                              onMessageReceived: (msg) {
                                                print(msg.message);
                                                if (msg.message ==
                                                    "subwayCompleteSuccess") {
                                                  _webViewControllerList[index]
                                                      ?.runJavascript(
                                                          "route()");
                                                }
                                              }),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterStart",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterEnd",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterTransfer",
                                              onMessageReceived: (msg) {}),
                                        },
                                        onWebViewCreated: (WebViewController
                                            webViewController) {
                                          _webViewControllerList[index] =
                                              webViewController;
                                        },
                                        onPageFinished: (url) {
                                          _webViewControllerList[index]
                                              ?.runJavascript(
                                                  "initMap('$city', '${segmentlist[0]["startname"]}', '${segmentlist[segmentlist.length - 1]["endname"]}')");
                                        },
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          color: Colors.lightBlue[100],
                                          child: ListTile(
                                            horizontalTitleGap: 5,
                                            contentPadding: EdgeInsets.zero,
                                            title: Container(
                                              margin: EdgeInsets.only(left: 15),
                                              alignment: Alignment.center,
                                              height: 40,
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    segmentlist.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      segmentlist.length) {
                                                    String lineID =
                                                        segmentlist[index]
                                                                ["bus_key_name"]
                                                            .toString()
                                                            .split("号")[0]
                                                            .substring(2);
                                                    String hexColorString =
                                                        segmentlist[index]
                                                                ["color"]
                                                            .toString();
                                                    if (hexColorString.length ==
                                                        6) {
                                                      hexColorString = "0xFF" +
                                                          hexColorString;
                                                    }
                                                    return CircleAvatar(
                                                      backgroundColor: Color(
                                                          int.parse(
                                                              hexColorString)),
                                                      radius: 15,
                                                      child: Text(
                                                        lineID,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  } else {
                                                    return Container(
                                                      // padding: EdgeInsets.only(left: 20),
                                                      // margin: EdgeInsets.only(
                                                      //     bottom: 15, top: 15),
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        "从 ${segmentlist[0]["startname"]} 至 ${segmentlist[segmentlist.length - 1]["endname"]}",
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    );
                                                  }
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      segmentlist.length - 1) {
                                                    return Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        size: 15,
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    width: 20,
                                                  );
                                                },
                                              ),
                                            ),
                                            trailing: IconButton(
                                              onPressed: () {
                                                pageController.nextPage(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.ease);
                                              },
                                              icon: Icon(
                                                  Icons.keyboard_arrow_right),
                                              iconSize: 35,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  );
                                } else if (index == 1) {
                                  String lineID = segmentlist[index - 1]
                                          ["bus_key_name"]
                                      .toString()
                                      .split("号")[0]
                                      .substring(2);
                                  return KeepAliveWrapper(
                                    child: Stack(children: [
                                      WebView(
                                        initialUrl:
                                            "http://0.0.0.0:9998/files/html/subway_map_station.html",
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                        javascriptChannels: {
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterRoute",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterStart",
                                              onMessageReceived: (msg) {
                                                print(msg.message);
                                                if (msg.message ==
                                                    "subwayCompleteSuccess") {
                                                  _webViewControllerList[index]
                                                      ?.runJavascript(
                                                          "setStartStation()");
                                                }
                                              }),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterEnd",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterTransfer",
                                              onMessageReceived: (msg) {}),
                                        },
                                        onWebViewCreated: (WebViewController
                                            webViewController) {
                                          _webViewControllerList[index] =
                                              webViewController;
                                        },
                                        onPageFinished: (url) {
                                          _webViewControllerList[index]
                                              ?.runJavascript(
                                                  "initMap('$city', '${segmentlist[0]["startname"]}', '${segmentlist[segmentlist.length - 1]["endname"]}')");
                                        },
                                      ),
                                      // Container(
                                      //     color: Colors.grey,
                                      //     alignment: Alignment.center,
                                      //     child: Text("$index")),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          color: Colors.lightBlue[100],
                                          child: ListTile(
                                            horizontalTitleGap: 5,
                                            contentPadding: EdgeInsets.zero,
                                            leading: IconButton(
                                              onPressed: () {
                                                pageController.previousPage(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.ease);
                                              },
                                              icon: Icon(
                                                  Icons.keyboard_arrow_left),
                                              iconSize: 35,
                                            ),
                                            title: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 40,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "$index/${transitTimes + 2}   从${segmentlist[index - 1]["startname"]}出发，乘坐${lineID}号线，前往${segmentlist[index - 1]["endname"]}",
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            trailing: IconButton(
                                              onPressed: () {
                                                pageController.nextPage(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.ease);
                                                // pageController.jumpToPage(index + 1);
                                              },
                                              icon: Icon(
                                                  Icons.keyboard_arrow_right),
                                              iconSize: 35,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  );
                                } else if (index == transitTimes + 2) {
                                  return KeepAliveWrapper(
                                    child: Stack(children: [
                                      WebView(
                                        initialUrl:
                                            "http://0.0.0.0:9998/files/html/subway_map_station.html",
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                        javascriptChannels: {
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterRoute",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterStart",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterEnd",
                                              onMessageReceived: (msg) {
                                                print(msg.message);
                                                if (msg.message ==
                                                    "subwayCompleteSuccess") {
                                                  _webViewControllerList[index]
                                                      ?.runJavascript(
                                                          "setEndStation()");
                                                }
                                              }),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterTransfer",
                                              onMessageReceived: (msg) {}),
                                        },
                                        onWebViewCreated: (WebViewController
                                            webViewController) {
                                          _webViewControllerList[index] =
                                              webViewController;
                                        },
                                        onPageFinished: (url) {
                                          _webViewControllerList[index]
                                              ?.runJavascript(
                                                  "initMap('$city', '${segmentlist[0]["startname"]}', '${segmentlist[segmentlist.length - 1]["endname"]}')");
                                        },
                                      ),
                                      // Container(
                                      //   color: Colors.grey,
                                      //   child: Text("$index"),
                                      //   alignment: Alignment.center,
                                      // ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          color: Colors.lightBlue[100],
                                          child: ListTile(
                                            horizontalTitleGap: 5,
                                            contentPadding: EdgeInsets.zero,
                                            leading: IconButton(
                                              onPressed: () {
                                                pageController.previousPage(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.ease);
                                              },
                                              icon: Icon(
                                                  Icons.keyboard_arrow_left),
                                              iconSize: 35,
                                            ),
                                            title: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 40,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "$index/${transitTimes + 2}   在${segmentlist[index - 2]["endname"]}下车",
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  );
                                } else {
                                  String lineID = segmentlist[index - 1]
                                          ["bus_key_name"]
                                      .toString()
                                      .split("号")[0]
                                      .substring(2);
                                  return KeepAliveWrapper(
                                    child: Stack(children: [
                                      WebView(
                                        initialUrl:
                                            "http://0.0.0.0:9998/files/html/subway_map_station.html",
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                        javascriptChannels: {
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterRoute",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterStart",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterEnd",
                                              onMessageReceived: (msg) {}),
                                          JavascriptChannel(
                                              name:
                                                  "subwayCompleteCallFlutterTransfer",
                                              onMessageReceived: (msg) {
                                                print(msg.message);
                                                if (msg.message ==
                                                    "subwayCompleteSuccess") {
                                                  _webViewControllerList[index]
                                                      ?.runJavascript(
                                                          "setTransferStation('${segmentlist[index - 1]["startname"]}')");
                                                }
                                              }),
                                        },
                                        onWebViewCreated: (WebViewController
                                            webViewController) {
                                          _webViewControllerList[index] =
                                              webViewController;
                                        },
                                        onPageFinished: (url) {
                                          _webViewControllerList[index]
                                              ?.runJavascript(
                                                  "initMap('$city', '${segmentlist[0]["startname"]}', '${segmentlist[segmentlist.length - 1]["endname"]}')");
                                        },
                                      ),
                                      // Container(
                                      //   color: Colors.grey,
                                      //   child: Text("$index"),
                                      //   alignment: Alignment.center,
                                      // ),
                                      Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            color: Colors.lightBlue[100],
                                            child: ListTile(
                                              horizontalTitleGap: 5,
                                              contentPadding: EdgeInsets.zero,
                                              leading: IconButton(
                                                onPressed: () {
                                                  pageController.previousPage(
                                                      duration: Duration(
                                                          milliseconds: 400),
                                                      curve: Curves.ease);
                                                },
                                                icon: Icon(
                                                    Icons.keyboard_arrow_left),
                                                iconSize: 35,
                                              ),
                                              title: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 40,
                                                child: ListView(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "$index/${transitTimes + 2}   在${segmentlist[index - 1]["startname"]}换乘，乘坐${lineID}号线，前往${segmentlist[index - 1]["endname"]}",
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              trailing: IconButton(
                                                onPressed: () {
                                                  pageController.nextPage(
                                                      duration: Duration(
                                                          milliseconds: 400),
                                                      curve: Curves.ease);
                                                  // pageController.jumpToPage(index + 1);
                                                },
                                                icon: Icon(
                                                    Icons.keyboard_arrow_right),
                                                iconSize: 35,
                                              ),
                                            ),
                                          ))
                                    ]),
                                  );
                                }
                              }),
                        ),
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
