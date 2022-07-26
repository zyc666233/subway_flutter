import 'package:flutter/material.dart';

import '../utils/expansion_tile_widget.dart';
import '../utils/log_utils.dart';

class RouteResultPage extends StatefulWidget {
  final Map<String, dynamic> routeResult;
  final String plan;
  RouteResultPage(this.routeResult, this.plan, {Key? key}) : super(key: key);

  @override
  State<RouteResultPage> createState() =>
      _RouteResultPageState(routeResult, plan);
}

class _RouteResultPageState extends State<RouteResultPage> {
  Map<String, dynamic> routeResult = {};
  String plan = "";
  _RouteResultPageState(this.routeResult, this.plan);

  late Map<String, dynamic> buslist;
  late List<dynamic> segmentlist;
  late String expensetime;
  late String expense;
  late int transitTimes;
  late int totalStations;
  List<Widget> arrow_icon_list = [];

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            color: Colors.grey[600],
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        title: Text(
          "$plan方案详情",
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
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Row(
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
            ),
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
                          (int.parse(expensetime) ~/ 60 + 1).toString(),
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
                            segmentlist[index ~/ 3]["color"].toString();
                        if (hexColorString.length == 6) {
                          hexColorString = "0xFF" + hexColorString;
                        }
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                          height: 15,
                                        )),
                                    // 第二层，圆形
                                    Positioned(
                                      top: 5,
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Color(int.parse(hexColorString)),
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
                                  segmentlist[index ~/ 3]["startname"],
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            ]);
                      } else if (index % 3 == 1) {
                        String lineID = segmentlist[index ~/ 3]["bus_key_name"]
                            .toString()
                            .split("号")[0]
                            .substring(2);
                        String hexColorString =
                            segmentlist[index ~/ 3]["color"].toString();
                        if (hexColorString.length == 6) {
                          hexColorString = "0xFF" + hexColorString;
                        }
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 实现左侧颜色条效果，矩形块
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(int.parse(hexColorString)),
                                  border: Border(
                                      top: BorderSide(
                                          width: 0,
                                          color:
                                              Color(int.parse(hexColorString))),
                                      bottom: BorderSide(
                                          width: 0,
                                          color: Color(
                                              int.parse(hexColorString)))),
                                ),
                                width: 20,
                                height: 30,
                              ),
                              // 线路标识，圆形
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  backgroundColor:
                                      Color(int.parse(hexColorString)),
                                  radius: 12,
                                  child: Text(
                                    lineID,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
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
                        List<String> passdepotname = segmentlist[index ~/ 3]
                                ["passdepotname"]
                            .toString()
                            .split(" ");
                        String passdepotcount = (int.parse(
                                    segmentlist[index ~/ 3]["passdepotcount"]) +
                                1)
                            .toString();
                        String drivertime =
                            ((int.parse(segmentlist[index ~/ 3]["drivertime"]) +
                                            int.parse(segmentlist[index ~/ 3]
                                                ["foottime"])) ~/
                                        60 +
                                    1)
                                .toString();
                        String hexColorString =
                            segmentlist[index ~/ 3]["color"].toString();
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
                          dividerColor: Colors.transparent,
                          title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 实现左侧颜色条效果，矩形块
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(hexColorString)),
                                    border: Border(
                                        top: BorderSide(
                                            width: 0,
                                            color: Color(
                                                int.parse(hexColorString))),
                                        bottom: BorderSide(
                                            width: 0,
                                            color: Color(
                                                int.parse(hexColorString)))),
                                  ),
                                  width: 20,
                                  height: 30,
                                ),
                                // 乘坐几站，用时多少
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      arrow_icon_list[index ~/ 3],
                                      Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          "乘坐${passdepotcount}站 （约${drivertime}分钟）",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                          children: [
                            ListView.builder(
                                itemCount: int.parse(
                                    segmentlist[index ~/ 3]["passdepotcount"]),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int id) {
                                  return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        // 站点名
                                        Container(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Text(
                                            "${passdepotname[id]}",
                                            style: TextStyle(fontSize: 16),
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
                            segmentlist[index ~/ 3 - 1]["color"].toString();
                        if (hexColorString_pre.length == 6) {
                          hexColorString_pre = "0xFF" + hexColorString_pre;
                        }
                        String hexColorString_after =
                            segmentlist[index ~/ 3]["color"].toString();
                        if (hexColorString_after.length == 6) {
                          hexColorString_after = "0xFF" + hexColorString_after;
                        }
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 实现左侧颜色条效果，颜色切换处
                              Column(
                                children: [
                                  // 上半，矩形 + 底部圆形
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(
                                              int.parse(hexColorString_pre)),
                                          border: Border(
                                              top: BorderSide(
                                                  width: 0,
                                                  color: Color(int.parse(
                                                      hexColorString_pre))),
                                              bottom: BorderSide(
                                                  width: 0,
                                                  color: Color(int.parse(
                                                      hexColorString_pre)))),
                                        ),
                                        width: 20,
                                        height: 10,
                                      ),
                                      CircleAvatar(
                                        backgroundColor: Color(
                                            int.parse(hexColorString_pre)),
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
                                                    color: Color(int.parse(
                                                        hexColorString_after))),
                                                bottom: BorderSide(
                                                    width: 0,
                                                    color: Color(int.parse(
                                                        hexColorString_after)))),
                                          ),
                                          width: 20,
                                          height: 10,
                                        ),
                                      ),
                                      CircleAvatar(
                                        backgroundColor: Color(
                                            int.parse(hexColorString_after)),
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
                                  segmentlist[index ~/ 3]["startname"],
                                  style: TextStyle(fontSize: 20),
                                ),
                              )
                            ]);
                      } else if (index == (transitTimes) * 3 + 3) {
                        String hexColorString =
                            segmentlist[index ~/ 3 - 1]["color"].toString();
                        if (hexColorString.length == 6) {
                          hexColorString = "0xFF" + hexColorString;
                        }
                        return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                        color: Color(int.parse(hexColorString)),
                                        border: Border(
                                            top: BorderSide(
                                                width: 0,
                                                color: Color(
                                                    int.parse(hexColorString))),
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
                                        backgroundColor:
                                            Color(int.parse(hexColorString)),
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
                                  segmentlist[index ~/ 3 - 1]["endname"],
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
      ),
    );
  }
}
