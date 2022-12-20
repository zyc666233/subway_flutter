import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subway_flutter/pages/modify_info_page.dart';
import 'package:subway_flutter/pages/pick_stations_page.dart';
import 'package:subway_flutter/utils/expansion_tile_widget.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:subway_flutter/utils/navigator_utils.dart';
import 'package:subway_flutter/utils/search_bar_wigdet.dart';
import 'package:subway_flutter/utils/shared_preferences_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

import 'route_result_page.dart';

String _userName = "";
String _userCity = "";
String _userHome = "";
String _userCompany = "";
String _walkHomeTime = "";
String _walkCompanyTime = "";
String _departureStation = "出发站点";
String _reachStation = "到达站点";
Color? greyTextColor = Colors.grey[500];
Color? blackTextColor = Colors.black;
Color? textColorStart = greyTextColor;
Color? textColorEnd = greyTextColor;
List<String> _addFrequentStations = [];
List<String> _addFrequentCities = [];
List<String> stationList = [];
Map<String, dynamic> routeResult = {};

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  WebViewController? _webViewController;

  var _scaffoldkey = new GlobalKey<ScaffoldState>(); //将Scaffold设置为全局变量
  final SystemUiOverlayStyle _style =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);

  var _imagePath = null;
  var _headImage = null;

  @override
  void initState() {
    super.initState();
    LogUtils.e('设备高度：${ScreenUtil().screenHeight}');
    LogUtils.e('设备宽度：${ScreenUtil().screenWidth}');
    LogUtils.e('实际高度与设计稿高度的比例：${ScreenUtil().scaleHeight}');
    LogUtils.e('实际宽度与设计稿宽度的比例：${ScreenUtil().scaleWidth}');
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    // SystemChrome.setSystemUIOverlayStyle(_style);

    return Scaffold(
      key: _scaffoldkey,
      // 侧边栏
      drawer: Drawer(
        child: Column(children: [
          UserAccountsDrawerHeader(
            // 用户头像
            currentAccountPicture: CircleAvatar(
              backgroundImage: _headImage,
            ),
            // 所在城市
            accountEmail: Text(
              "所在城市：${_userCity}",
              style: TextStyle(fontSize: 12.sp),
            ),
            // 用户名
            accountName: Text(
              _userName,
              style: TextStyle(fontSize: 16.sp),
            ),
            // 编辑按钮
            otherAccountsPictures: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: 1.w, right: 1.w, top: 9.h, bottom: 9.h),
                child: TextButton(
                    style: ButtonStyle(
                      //圆角
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r))),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.grey[100]),
                      // minimumSize: MaterialStateProperty.all(Size(1, 2)),
                      padding: MaterialStateProperty.all(EdgeInsets.only(
                          left: 2.w, right: 2.w, top: 1.h, bottom: 1.h)),
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 12.sp)),
                      // side: MaterialStateProperty.all(
                      //     BorderSide(color: Colors.white)),
                    ),
                    onPressed: () => modifyInfo(),
                    child: Text("编辑",
                        style: TextStyle(
                          color: Colors.blue[600],
                        ))),
              ),
            ],
          ),
          // 显示的站点列表
          Container(
            padding: EdgeInsets.only(bottom: 5.h),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(width: 0.8.w, color: Colors.grey.shade400))),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.home)),
              title: Text(
                _userHome,
                style: TextStyle(fontSize: 18.sp),
              ),
              trailing: Text(
                "步行时长：${_walkHomeTime}",
                style: TextStyle(fontSize: 15.sp),
              ),
              onTap: () {
                if (_departureStation == "出发站点" || _reachStation == "到达站点") {
                  showStationOnMap(_userHome);
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(width: 0.8.w, color: Colors.grey.shade400))),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.business)),
              title: Text(
                _userCompany,
                style: TextStyle(fontSize: 18.sp),
              ),
              trailing: Text(
                "步行时长：${_walkCompanyTime}",
                style: TextStyle(fontSize: 15.sp),
              ),
              onTap: () {
                if (_departureStation == "出发站点" || _reachStation == "到达站点") {
                  showStationOnMap(_userCompany);
                }
              },
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                padding: EdgeInsets.only(left: 8.w),
                child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount: _addFrequentStations.length,
                    itemBuilder: (context, index) {
                      // 创建一个富文本，匹配的内容特别显示
                      return Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.8.w,
                                    color: Colors.grey.shade400))),
                        child: ListTile(
                          style: ListTileStyle.list,
                          leading: Icon(Icons.subway),
                          title: Text(
                            _addFrequentStations[index],
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          onTap: () {
                            if (_departureStation == "出发站点" ||
                                _reachStation == "到达站点") {
                              showStationOnMap(_addFrequentStations[index]);
                            }
                          },
                        ),
                      );
                    }),
              ),
            ),
          )
        ]),
      ),
      // 页面主体
      body: Column(
        children: [
          // 搜索栏
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Color.fromARGB(255, 245, 245, 245),
                  width: 0.0), //灰色的一层边框
              color: Color.fromARGB(255, 240, 240, 240),
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
            ),
            padding: EdgeInsets.fromLTRB(10.w, 40.h, 20.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.all(0.r),
                    icon: Icon(Icons.person),
                    iconSize: 40.r,
                    onPressed: () {
                      if (!_scaffoldkey.currentState!.isDrawerOpen) {
                        _scaffoldkey.currentState?.openDrawer();
                      }
                    },
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      Container(
                        decoration: new BoxDecoration(
                          border: Border.all(
                              color: Colors.grey, width: 0.0.w), //灰色的一层边框
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(0.r)),
                        ),
                        alignment: Alignment.center,
                        // width: 100,
                        height: 40.h,
                        // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
                        padding: EdgeInsets.only(left: 6.w, right: 6.w),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                )),
                            Expanded(
                                flex: 6,
                                child: InkWell(
                                  child: Text(
                                    _departureStation,
                                    style: TextStyle(
                                        fontSize: 16.sp, color: textColorStart),
                                  ),
                                  onTap: () async {
                                    //这里是跳转搜索界面的关键
                                    var station_back = await showSearch(
                                        context: context,
                                        delegate: SearchBarDelegate());
                                    print(station_back);
                                    if (station_back != null &&
                                        station_back != '') {
                                      setState(() {
                                        _departureStation = station_back;
                                        textColorStart = blackTextColor;
                                        if (station_back == _reachStation) {
                                          _reachStation = "到达站点";
                                          textColorEnd = greyTextColor;
                                        }
                                        setStartStationOnMap(_departureStation);
                                      });
                                    }
                                  },
                                )),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _departureStation = "出发站点";
                                      textColorStart = greyTextColor;
                                      _webViewController
                                          ?.runJavascript("clearStart()");
                                      _webViewController
                                          ?.runJavascript("clearRoute()");
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                          border: Border.all(
                              color: Colors.grey, width: 0.0.w), //灰色的一层边框
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(0.r)),
                        ),
                        alignment: Alignment.center,
                        // width: 100,
                        height: 40.h,
                        // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
                        padding: EdgeInsets.only(left: 6.w, right: 6.w),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                )),
                            Expanded(
                                flex: 6,
                                child: InkWell(
                                  child: Text(
                                    _reachStation,
                                    style: TextStyle(
                                        fontSize: 16.sp, color: textColorEnd),
                                  ),
                                  onTap: () async {
                                    //这里是跳转搜索界面的关键
                                    var station_back = await showSearch(
                                        context: context,
                                        delegate: SearchBarDelegate());
                                    print(station_back);
                                    if (station_back != null &&
                                        station_back != '') {
                                      setState(() {
                                        _reachStation = station_back;
                                        textColorEnd = blackTextColor;
                                        if (station_back == _departureStation) {
                                          _departureStation = "出发站点";
                                          textColorStart = greyTextColor;
                                        }
                                        setEndStationOnMap(_reachStation);
                                      });
                                    }
                                  },
                                )),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _reachStation = "到达站点";
                                      textColorEnd = greyTextColor;
                                      _webViewController
                                          ?.runJavascript("clearEnd()");
                                      _webViewController
                                          ?.runJavascript("clearRoute()");
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      // SearchBar(
                      //   hintText: _departureStation,
                      //   stationCallBack: (station_name) {
                      //     LogUtils.e(station_name);
                      //     setStartStationOnMap(station_name);
                      //   },

                      // ),
                      // SearchBar(
                      //   hintText: _reachStation,
                      //   stationCallBack: (station_name) {
                      //     LogUtils.e(station_name);
                      //     setEndStationOnMap(station_name);
                      //   },
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // 地铁图
          Expanded(
              child: WebView(
            initialUrl: "http://0.0.0.0:9998/files/html/subway_map.html",
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: {
              // 地铁图绘制完成后接收消息
              JavascriptChannel(
                  name: "subwayCompletedCallFlutter",
                  onMessageReceived: (msg) async {
                    print(msg.message);
                    // Map<String, dynamic> stationInfo = jsonDecode(msg.message);
                    // Directory tempDir = await getTemporaryDirectory();
                    // String tempPath = tempDir.path;
                    // print(tempPath);
                    // File data = File("$tempPath/data.json");
                    // String cityList = "";
                    // for (var item in stationInfo.keys) {
                    //   String temp = stationInfo[item]["name"].toString();
                    //   if (temp.endsWith("市")) {
                    //     temp = temp.split("市")[0];
                    //   } else if (temp.endsWith("特别行政区")) {
                    //     temp = temp.split("特别行政区")[0];
                    //   }
                    //   cityList += (temp + '\n');
                    // }
                    // data.writeAsStringSync(cityList);
                  }),
              // 地铁图站点被点击时接收消息
              JavascriptChannel(
                  name: "touchStationCallFlutter",
                  onMessageReceived: (msg) {
                    print(msg.message);
                    Map<String, dynamic> stationInfo = jsonDecode(msg.message);
                    showStationDetails(stationInfo);
                  }),
              // 通过地铁图设置起点或终点时接收消息（暂不使用）
              JavascriptChannel(
                  name: "stationBackCallFlutter",
                  onMessageReceived: (msg) {
                    print(msg.message);
                    Map<String, dynamic> stationInfo = jsonDecode(msg.message);
                    if (stationInfo["type"] == "start") {
                      setState(() {
                        _departureStation = stationInfo["name"];
                        textColorStart = blackTextColor;
                        if (stationInfo["name"] == _reachStation) {
                          _reachStation = "到达站点";
                          textColorEnd = greyTextColor;
                        }
                      });
                    }
                    if (stationInfo["type"] == "end") {
                      setState(() {
                        _reachStation = stationInfo["name"];
                        textColorEnd = blackTextColor;
                        if (stationInfo["name"] == _departureStation) {
                          _departureStation = "出发站点";
                          textColorStart = greyTextColor;
                        }
                      });
                    }
                  }),
              // 触碰地铁图空白处时接收消息
              JavascriptChannel(
                  name: "touchMapCallFlutter",
                  onMessageReceived: (msg) {
                    print(msg.message);
                    if (msg.message == "true") {
                      setState(() {
                        textColorStart = textColorEnd = greyTextColor;
                        _departureStation = "出发站点";
                        _reachStation = "到达站点";
                      });
                    }
                  }),
              // 地铁图线路规划方法执行完毕后接收消息
              JavascriptChannel(
                  name: "routeCompletedCallFlutter",
                  onMessageReceived: (msg) async {
                    // LogUtils.e(msg.message);
                    routeResult = jsonDecode(msg.message);
                    // Directory tempDir = await getTemporaryDirectory();
                    // String tempPath = tempDir.path;
                    // File route_result = File("$tempPath/route_result.txt");
                    // route_result.writeAsStringSync(msg.message);
                    if (routeResult["info"] == "success") {
                      showRouteResult(routeResult);
                    }
                  }),
            },
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            onPageFinished: (url) async {
              _webViewController?.runJavascript("setAdcode('$_userCity')");
            },
          )),
        ],
      ),
      // 悬浮按钮用于查看搜索结果
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          if (_departureStation != "出发站点" &&
              _reachStation != "到达站点" &&
              routeResult != {}) {
            showRouteResult(routeResult);
          }
        },
      ),
    );
  }

  // 页面初始化工作
  void initialization() async {
    // 获取本地保存的用户信息
    await SPUtil.init();
    _imagePath = await SPUtil.getString("avatarImagePath");
    var userName = await SPUtil.getString("userName");
    var userCity = await SPUtil.getString("userCity");
    var userHome = await SPUtil.getString("userHome");
    var userCompany = await SPUtil.getString("userCompany");
    var walkHomeTime = await SPUtil.getString("walkHomeTime");
    var walkCompanyTime = await SPUtil.getString("walkCompanyTime");
    var addFrequentCities = await SPUtil.getString("addFrequentCities");
    var addFrequentStations = await SPUtil.getString("addFrequentStations");
    _addFrequentCities = jsonDecode(addFrequentCities!).cast<String>();
    _addFrequentStations = jsonDecode(addFrequentStations!).cast<String>();
    print(_addFrequentCities);
    print(_addFrequentStations);
    // 获取本地保存的用户信息
    if (userName != null) {
      setState(() {
        _userName = userName;
      });
    }
    if (userCity != null) {
      setState(() {
        _userCity = userCity;
      });
    }
    if (userHome != null) {
      setState(() {
        _userHome = userHome;
      });
    }
    if (userCompany != null) {
      setState(() {
        _userCompany = userCompany;
      });
    }
    if (walkHomeTime != null) {
      setState(() {
        _walkHomeTime = walkHomeTime;
      });
    }
    if (walkCompanyTime != null) {
      setState(() {
        _walkCompanyTime = walkCompanyTime;
      });
    }
    if (_imagePath != null) {
      setState(() {
        _headImage = FileImage(File(_imagePath));
      });
    }
    // 读取已开通地铁的城市列表
    stationList = [];
    if (userCity != '') {
      // 读取已开通地铁的城市列表
      String cityStationsString =
          await rootBundle.loadString("assets/city_stations.json");
      Map<String, dynamic> cityStationsResult = jsonDecode(cityStationsString);
      if (cityStationsResult.containsKey(userCity)) {
        stationList = cityStationsResult[userCity].cast<String>();
      }
      LogUtils.e("msyydsyydsyyds " + stationList.length.toString());
    }
  }

  // 跳转到用户信息编辑页面
  void modifyInfo() {
    NavigatorUtils.pushPageByFade(context: context, targPage: ModifyInfoPage());
  }

  // 点击地图上的站点
  void showStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      Map<String, dynamic> station_info;
      if (Platform.isAndroid) {
        station_info = jsonDecode(jsonDecode(value));
      } else {
        station_info = jsonDecode(value);
      }
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      if (_scaffoldkey.currentState!.isDrawerOpen) {
        BuildContext? currentContext = _scaffoldkey.currentContext;
        Navigator.pop(currentContext!);
      }
      _webViewController?.runJavascript("touchStation('$station_id')");
      showStationDetails(station_info["stationList"][0]);
    });
  }

  // 在地图上标注起点
  void setStartStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      Map<String, dynamic> station_info;
      if (Platform.isAndroid) {
        station_info = jsonDecode(jsonDecode(value));
      } else {
        station_info = jsonDecode(value);
      }
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      _webViewController?.runJavascript("setStartStation('$station_id')");
    });
    // _webViewController?.runJavascript("deleteMysubway()");
    // _webViewController?.runJavascript("createMap('南京市')");
  }

  // 在地图上标注终点
  void setEndStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      Map<String, dynamic> station_info;
      if (Platform.isAndroid) {
        station_info = jsonDecode(jsonDecode(value));
      } else {
        station_info = jsonDecode(value);
      }
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      _webViewController?.runJavascript("setEndStation('$station_id')");
    });
  }

  // 展示线路规划结果
  void showRouteResult(Map<String, dynamic> routeResult) async {
    routeResult = routeResult["data"];
    Map<String, dynamic> buslist = routeResult["buslist"][0];
    List<dynamic> segmentlist = buslist["segmentlist"];
    String expensetime = buslist["expensetime"]; // 全程花费的时间
    int transitTimes = segmentlist.length - 1; // 中转次数
    int totalStations = 0; // 全程经过的站点总数
    String expense = buslist["expense"]; // 全程票价
    if (expense.endsWith(".0")) {
      expense = expense.substring(0, expense.length - 2);
    }
    LogUtils.e(expense);
    LogUtils.e((int.parse(expensetime) / 60).toString());
    LogUtils.e(transitTimes.toString());
    for (var i = 0; i < segmentlist.length; i++) {
      LogUtils.e(
          segmentlist[i]["bus_key_name"].toString().split("号")[0].substring(2));
      LogUtils.e((int.parse(segmentlist[i]["passdepotcount"].toString()) + 1)
          .toString());
      totalStations +=
          int.parse(segmentlist[i]["passdepotcount"].toString()) + 1;
    }
    _webViewController?.runJavascript("stopOpt()");
    LogUtils.e("stopOpt");
    LogUtils.e(totalStations.toString());

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      //自定义底部弹窗布局
      shape: new RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0.r),
            topRight: Radius.circular(20.0.r)),
      ),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _webViewController?.runJavascript("allowOpt()");
            LogUtils.e("allowOpt");
            return true;
          },
          child: Container(
            // height: MediaQuery.of(context).size.height / 2.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 弹窗标题栏
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 0.8.w, color: Colors.grey.shade400))),
                  child: ListTile(
                    title: Text(
                      "查询结果",
                      style: TextStyle(fontSize: 20.sp),
                      textAlign: TextAlign.center,
                    ),
                    trailing: IconButton(
                      padding: EdgeInsets.only(bottom: 1.h),
                      onPressed: () {
                        _webViewController?.runJavascript("allowOpt()");
                        LogUtils.e("allowOpt");
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 40.r,
                    ),
                    leading: IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.transparent,
                      ),
                      iconSize: 35.r,
                    ),
                  ),
                ),
                // 起点站和终点站的提示信息栏
                Container(
                  padding: EdgeInsets.only(left: 20.w),
                  margin: EdgeInsets.only(bottom: 20.h, top: 15.h),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "从 $_departureStation 至 $_reachStation",
                    style: TextStyle(fontSize: 16.sp),
                    textAlign: TextAlign.start,
                  ),
                ),
                // 最便宜策略结果展示栏
                Container(
                  margin: EdgeInsets.only(bottom: 15.h),
                  child: ListTile(
                    horizontalTitleGap: 0.w,
                    leading: Container(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Image(
                            image: AssetImage(
                                "assets/images/green_triangle.png"))),
                    title: Row(
                      children: [
                        // 乘坐的地铁线路
                        Expanded(
                            flex: 11,
                            child: Container(
                              height: 40.h,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: segmentlist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String lineID = segmentlist[index]
                                          ["bus_key_name"]
                                      .toString()
                                      .split("号")[0]
                                      .substring(2);
                                  String hexColorString =
                                      segmentlist[index]["color"].toString();
                                  if (hexColorString.length == 6) {
                                    hexColorString = "0xFF" + hexColorString;
                                  }
                                  return CircleAvatar(
                                    backgroundColor:
                                        Color(int.parse(hexColorString)),
                                    radius: 15.r,
                                    child: Text(
                                      lineID,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(left: 5.w, right: 5.w),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 15.r,
                                    ),
                                  );
                                },
                              ),
                            )),
                        // 全部行程的汇总信息
                        Expanded(
                            flex: 10,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(expense),
                                        Text("元")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(totalStations.toString()),
                                        Text("站")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(transitTimes.toString()),
                                        Text("换")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text((int.parse(expensetime) ~/ 60 + 1)
                                            .toString()),
                                        Text("分")
                                      ])),
                                ],
                              ),
                            ))
                      ],
                    ),
                    trailing: IconButton(
                        iconSize: 35.r,
                        onPressed: () {
                          _webViewController?.runJavascript("allowOpt()");
                          LogUtils.e("allowOpt");
                          goToRouteResultPage(routeResult, "最少换乘", _userCity);
                        },
                        icon: Icon(Icons.navigate_next)),
                  ),
                ),
                // 最快速策略结果展示栏
                Container(
                  margin: EdgeInsets.only(bottom: 15.h),
                  child: ListTile(
                    horizontalTitleGap: 0.w,
                    leading: Container(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Image(
                            image:
                                AssetImage("assets/images/blue_triangle.png"))),
                    title: Row(
                      children: [
                        // 乘坐的地铁线路
                        Expanded(
                            flex: 11,
                            child: Container(
                              height: 40.h,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: segmentlist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String lineID = segmentlist[index]
                                          ["bus_key_name"]
                                      .toString()
                                      .split("号")[0]
                                      .substring(2);
                                  String hexColorString =
                                      segmentlist[index]["color"].toString();
                                  if (hexColorString.length == 6) {
                                    hexColorString = "0xFF" + hexColorString;
                                  }
                                  return CircleAvatar(
                                    backgroundColor:
                                        Color(int.parse(hexColorString)),
                                    radius: 15.r,
                                    child: Text(
                                      lineID,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(left: 5.w, right: 5.w),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 15.r,
                                    ),
                                  );
                                },
                              ),
                            )),
                        // 全部行程的汇总信息
                        Expanded(
                            flex: 10,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(expense),
                                        Text("元")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(totalStations.toString()),
                                        Text("站")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(transitTimes.toString()),
                                        Text("换")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text((int.parse(expensetime) ~/ 60 + 1)
                                            .toString()),
                                        Text("分")
                                      ])),
                                ],
                              ),
                            ))
                      ],
                    ),
                    trailing: IconButton(
                        iconSize: 35.r,
                        onPressed: () {
                          _webViewController?.runJavascript("allowOpt()");
                          LogUtils.e("allowOpt");
                          goToRouteResultPage(routeResult, "最快速", _userCity);
                        },
                        icon: Icon(Icons.navigate_next)),
                  ),
                ),
                // 最舒适策略结果展示栏
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 0.8.w, color: Colors.grey.shade400))),
                  margin: EdgeInsets.only(bottom: 15.h),
                  child: ListTile(
                    horizontalTitleGap: 0.w,
                    leading: Container(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Image(
                            image:
                                AssetImage("assets/images/red_triangle.png"))),
                    title: Row(
                      children: [
                        // 乘坐的地铁线路
                        Expanded(
                            flex: 11,
                            child: Container(
                              height: 40.h,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: segmentlist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String lineID = segmentlist[index]
                                          ["bus_key_name"]
                                      .toString()
                                      .split("号")[0]
                                      .substring(2);
                                  String hexColorString =
                                      segmentlist[index]["color"].toString();
                                  if (hexColorString.length == 6) {
                                    hexColorString = "0xFF" + hexColorString;
                                  }
                                  return CircleAvatar(
                                    backgroundColor:
                                        Color(int.parse(hexColorString)),
                                    radius: 15.r,
                                    child: Text(
                                      lineID,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(left: 5.w, right: 5.w),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 15.r,
                                    ),
                                  );
                                },
                              ),
                            )),
                        // 全部行程的汇总信息
                        Expanded(
                            flex: 10,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(expense),
                                        Text("元")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(totalStations.toString()),
                                        Text("站")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text(transitTimes.toString()),
                                        Text("换")
                                      ])),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      child: Column(children: [
                                        Text((int.parse(expensetime) ~/ 60 + 1)
                                            .toString()),
                                        Text("分")
                                      ])),
                                ],
                              ),
                            ))
                      ],
                    ),
                    trailing: IconButton(
                        iconSize: 35.r,
                        onPressed: () {
                          _webViewController?.runJavascript("allowOpt()");
                          LogUtils.e("allowOpt");
                          goToRouteResultPage(routeResult, "最舒适", _userCity);
                        },
                        icon: Icon(Icons.navigate_next)),
                  ),
                ),
                // 颜色与对应策略的提示信息
                Container(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Row(
                    children: [
                      Container(
                          height: 40.h,
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Image(
                              image: AssetImage(
                                  "assets/images/green_triangle.png"))),
                      Container(
                        child: Text("少换乘"),
                        margin: EdgeInsets.only(right: 30.w),
                        padding: EdgeInsets.only(bottom: 20.h),
                      ),
                      Container(
                          height: 40.h,
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Image(
                              image: AssetImage(
                                  "assets/images/blue_triangle.png"))),
                      Container(
                        child: Text("最快速"),
                        margin: EdgeInsets.only(right: 30.w),
                        padding: EdgeInsets.only(bottom: 20.h),
                      ),
                      Container(
                          height: 40.h,
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Image(
                              image: AssetImage(
                                  "assets/images/red_triangle.png"))),
                      Container(
                        child: Text("最舒适"),
                        margin: EdgeInsets.only(right: 30.w),
                        padding: EdgeInsets.only(bottom: 20.h),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 跳转到线路规划详情页面
  void goToRouteResultPage(
      Map<String, dynamic> routeResult, String plan, String city) {
    NavigatorUtils.pushPageByFade(
        context: context, targPage: RouteResultPage(routeResult, plan, city));
  }

  // 通过底部弹窗在地图上显示站点信息
  void showStationDetails(Map<String, dynamic> stationInfo) async {
    IconData arrow = Icons.arrow_drop_up;
    String stationName = stationInfo["name"];
    List<dynamic> referLines = stationInfo["referlines"];
    List<Widget> referLinesList = [];
    LogUtils.e(stationName);
    for (var i = 0; i < referLines.length; i++) {
      LogUtils.e(referLines[i]["name"]);
      String hexColorString = referLines[i]["color"].toString();
      if (hexColorString.length == 6) {
        hexColorString = "0xFF" + hexColorString;
      }
      referLinesList.add(Container(
        padding:
            EdgeInsets.only(left: 10.w, right: 10.w, top: 3.h, bottom: 3.h),
        margin: EdgeInsets.only(right: 10.r),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.r)),
            border: Border.all(color: Colors.black),
            color: Color(
              int.parse(hexColorString),
            )),
        child: Text(
          referLines[i]["name"],
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ));
    }
    _webViewController?.runJavascript("stopOpt()");
    LogUtils.e("stopOpt");

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      //自定义底部弹窗布局
      shape: new RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0.r),
            topRight: Radius.circular(20.0.r)),
      ),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _webViewController?.runJavascript("allowOpt()");
            LogUtils.e("allowOpt");
            return true;
          },
          child: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // // 弹窗标题栏
              // Container(
              //     height: 40,
              //     decoration: BoxDecoration(
              //         border: Border(
              //             bottom: BorderSide(width: 0.8, color: Colors.grey))),
              //     alignment: Alignment.center,
              //     child: IconButton(
              //       padding: EdgeInsets.all(0),
              //       onPressed: null,
              //       icon: Icon(
              //         arrow,
              //         // color: Colors.grey,
              //       ),
              //       iconSize: 35,
              //     )), // 起点站和终点站的提示信息栏
              // 站点详情
              UserExpansionTile(
                allowVerticalDrag: true,
                title: Container(
                    // padding: EdgeInsets.only(left: 20),
                    margin: EdgeInsets.only(bottom: 20.h, top: 20.h),
                    alignment: Alignment.center,
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 10.w),
                      horizontalTitleGap: 10.w,
                      // 设为起点和终点的按钮
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5.w),
                            child: TextButton(
                                style: ButtonStyle(
                                  //圆角
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.r))),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightBlue),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(1.w, 2.h)),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.only(
                                          left: 5.w,
                                          right: 5.w,
                                          top: 5.h,
                                          bottom: 5.h)),
                                  textStyle: MaterialStateProperty.all(
                                      TextStyle(fontSize: 10.sp)),
                                  side: MaterialStateProperty.all(
                                      BorderSide(color: Colors.black)),
                                ),
                                onPressed: () {
                                  _webViewController
                                      ?.runJavascript("allowOpt()");
                                  LogUtils.e("allowOpt");
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _departureStation = stationName;
                                    textColorStart = blackTextColor;
                                    if (stationName == _reachStation) {
                                      _reachStation = "到达站点";
                                      textColorEnd = greyTextColor;
                                    }
                                    setStartStationOnMap(_departureStation);
                                  });
                                },
                                child: Text("设为起点",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ))),
                          ),
                          Container(
                            // padding: EdgeInsets.only(
                            //     left: 1, right: 1, top: 9, bottom: 9),
                            child: TextButton(
                                style: ButtonStyle(
                                  //圆角
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.r))),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.pink[200]),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(1.w, 2.h)),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.only(
                                          left: 5.w,
                                          right: 5.w,
                                          top: 5.h,
                                          bottom: 5.h)),
                                  textStyle: MaterialStateProperty.all(
                                      TextStyle(fontSize: 10.sp)),
                                  side: MaterialStateProperty.all(
                                      BorderSide(color: Colors.black)),
                                ),
                                onPressed: () {
                                  _webViewController
                                      ?.runJavascript("allowOpt()");
                                  LogUtils.e("allowOpt");
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _reachStation = stationName;
                                    textColorEnd = blackTextColor;
                                    if (stationName == _departureStation) {
                                      _departureStation = "出发站点";
                                      textColorStart = greyTextColor;
                                    }
                                    setEndStationOnMap(_reachStation);
                                  });
                                },
                                child: Text("设为终点",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ))),
                          ),
                        ],
                      ),
                      // 站点名和所经过的线路
                      title: Container(
                        padding: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Colors.lightBlue.shade200))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  stationName,
                                  style: TextStyle(fontSize: 25.sp),
                                )),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: referLinesList,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 20.w),
                      horizontalTitleGap: 20.w,
                      minLeadingWidth: 0.w,
                      leading: Icon(Icons.wifi),
                      title: Text(
                        "车站信息",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 20.w),
                      horizontalTitleGap: 20.w,
                      minLeadingWidth: 0.w,
                      leading: Icon(Icons.wifi),
                      title: Text(
                        "首末班车时刻表",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 20.w),
                      horizontalTitleGap: 20.w,
                      minLeadingWidth: 0.w,
                      leading: Icon(Icons.wifi),
                      title: Text(
                        "车站设施",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 20.w),
                      horizontalTitleGap: 20.w,
                      minLeadingWidth: 0.w,
                      leading: Icon(Icons.wifi),
                      title: Text(
                        "车站可达性",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: ListTile(
                      minVerticalPadding: 0.h,
                      contentPadding: EdgeInsets.only(left: 20.w, right: 20.w),
                      horizontalTitleGap: 20.w,
                      minLeadingWidth: 0.w,
                      leading: Icon(Icons.wifi),
                      title: Text(
                        "车站地图",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: null,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }
}

// 搜索功能
class SearchBarDelegate extends SearchDelegate<String> {
  String get searchFieldLabel => "搜索站点";

  // 搜索条右侧的按钮执行方法，在这里方法里放入一个clear图标，点击图标清空搜索的内容。
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          //搜索值为空
          query = "";
          showSuggestions(context);
        },
      )
    ];
  }

  // 搜索栏左侧的图标和功能，点击时关闭整个搜索页面
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        //点击时关闭整个搜索页面
        onPressed: () => close(context, ''));
  }

  // 搜索内容确定后
  @override
  Widget buildResults(BuildContext context) {
    bool flag = false;
    if (stationList.contains(query)) {
      flag = true;
    }
    return flag == true
        ? ListView(
            children: [
              ListTile(
                leading: Icon(Icons.subway),
                title: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp),
                      children: [
                        TextSpan(
                            text: query,
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.sp))
                      ]),
                ),
                onTap: () {
                  Navigator.of(context).pop(query);
                },
              ),
            ],
          )
        : Center(
            child: Text(
              "没有搜索到此站点",
              style: TextStyle(fontSize: 18.sp),
            ),
          );
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> userList = [];
    if (_userHome != '') {
      userList.add(_userHome);
    }
    if (_userCompany != '') {
      userList.add(_userCompany);
    }
    //判断集合中的字符串是否以搜索框内输入的字符串开头，是则返回true，并将结果以list的方式储存在suggestionsList里
    final suggestionsList = query.isEmpty
        ? (userList + _addFrequentStations)
        : stationList.where((input) => input.startsWith(query)).toList();

    return ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, index) {
          if (query.isEmpty && _userHome != '' && index == 0) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.home,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
          if (query.isEmpty &&
              ((_userCompany != '' && _userHome != '' && index == 1) ||
                  (_userCompany != '' && _userHome == '' && index == 0))) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.location_city,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
          if (query.isEmpty && index >= userList.length) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.star,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
          return InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                leading: Icon(Icons.subway),
                title: RichText(
                  //富文本
                  text: TextSpan(
                      text: suggestionsList[index].substring(0, query.length),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp),
                      children: [
                        TextSpan(
                            text:
                                suggestionsList[index].substring(query.length),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 18.sp))
                      ]),
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(suggestionsList[index]);
            },
          );
        });
  }
}
