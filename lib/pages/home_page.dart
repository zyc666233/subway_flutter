import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subway_flutter/pages/modify_info_page.dart';
import 'package:subway_flutter/pages/pick_stations_page.dart';
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
  String _filePath = "assets/files/subway_map_test.html";
  String _jsPath = 'assets/files/adcode.js';
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? _webViewController;

  var _scaffoldkey = new GlobalKey<ScaffoldState>(); //将Scaffold设置为全局变量
  final SystemUiOverlayStyle _style =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);

  var _imagePath = null;
  var _headImage = null;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    // SystemChrome.setSystemUIOverlayStyle(_style);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: Config.themeData,
      home: Scaffold(
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
                style: TextStyle(fontSize: 12),
              ),
              // 用户名
              accountName: Text(
                _userName,
                style: TextStyle(fontSize: 16),
              ),
              // 编辑按钮
              otherAccountsPictures: <Widget>[
                Container(
                  padding:
                      EdgeInsets.only(left: 1, right: 1, top: 9, bottom: 9),
                  child: TextButton(
                      style: ButtonStyle(
                        //圆角
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[100]),
                        // minimumSize: MaterialStateProperty.all(Size(1, 2)),
                        padding: MaterialStateProperty.all(EdgeInsets.only(
                            left: 2, right: 2, top: 1, bottom: 1)),
                        textStyle:
                            MaterialStateProperty.all(TextStyle(fontSize: 12)),
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
              padding: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.home)),
                title: Text(
                  _userHome,
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Text(
                  "步行时长：${_walkHomeTime}",
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () => showStationOnMap(_userHome),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.business)),
                title: Text(
                  _userCompany,
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Text(
                  "步行时长：${_walkCompanyTime}",
                  style: TextStyle(fontSize: 15),
                ),
                onTap: () => showStationOnMap(_userCompany),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Container(
                  padding: EdgeInsets.only(left: 8),
                  child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: _addFrequentStations.length,
                      itemBuilder: (context, index) {
                        // 创建一个富文本，匹配的内容特别显示
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.8,
                                      color: Colors.grey.shade400))),
                          child: ListTile(
                            style: ListTileStyle.list,
                            leading: Icon(Icons.subway),
                            title: Text(
                              _addFrequentStations[index],
                              style: TextStyle(fontSize: 18),
                            ),
                            onTap: () {
                              if (_departureStation == "出发站点" || _reachStation == "到达站点"){
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
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(10, 40, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.person),
                      iconSize: 40,
                      onPressed: () {
                        if (!_scaffoldkey.currentState!.isDrawerOpen) {
                          _scaffoldkey.currentState?.openDrawer();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Container(
                          decoration: new BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 0.0), //灰色的一层边框
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          alignment: Alignment.center,
                          // width: 100,
                          height: 40,
                          // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
                          padding: EdgeInsets.only(left: 6, right: 6),
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
                                      style: TextStyle(fontSize: 16),
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
                                          setStartStationOnMap(
                                              _departureStation);
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
                                        _webViewController
                                            ?.runJavascript("clearStart()");
                                      });
                                    },
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          decoration: new BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 0.0), //灰色的一层边框
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          alignment: Alignment.center,
                          // width: 100,
                          height: 40,
                          // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
                          padding: EdgeInsets.only(left: 6, right: 6),
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
                                      style: TextStyle(fontSize: 16),
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
                                        _webViewController
                                            ?.runJavascript("clearEnd()");
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
              initialUrl: "http://0.0.0.0:9998/files/html/subway_map_test.html",
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: {
                JavascriptChannel(
                    name: "stationBackCallFlutter",
                    onMessageReceived: (msg) {
                      print(msg.message);
                      Map<String, dynamic> stationInfo =
                          jsonDecode(msg.message);
                      if (stationInfo["type"] == "start") {
                        setState(() {
                          _departureStation = stationInfo["name"];
                        });
                      }
                      if (stationInfo["type"] == "end") {
                        setState(() {
                          _reachStation = stationInfo["name"];
                        });
                      }
                    }),
                JavascriptChannel(
                    name: "touchMapCallFlutter",
                    onMessageReceived: (msg) {
                      print(msg.message);
                      if (msg.message == "true") {
                        setState(() {
                          _departureStation = "出发站点";
                          _reachStation = "到达站点";
                        });
                      }
                    }),
                JavascriptChannel(
                    name: "routeCompletedCallFlutter",
                    onMessageReceived: (msg) async {
                      // LogUtils.e(msg.message);
                      routeResult = jsonDecode(msg.message);
                      Directory tempDir = await getTemporaryDirectory();
                      String tempPath = tempDir.path;
                      File route_result = File("$tempPath/route_result.txt");
                      route_result.writeAsStringSync(msg.message);
                      showRouteResult(routeResult);
                    }),
              },
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
                // _loadHtmlFromAssets();
              },
              onPageFinished: (url) async {
                // print(url);
                // String jsContent = await rootBundle.loadString(jsPath);
                // _webViewController?.runJavascript(jsContent);
              },
            )),
          ],
        ),
        // 悬浮按钮用于查看搜索结果
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: (){
            if(_departureStation != "出发站点" && _reachStation != "到达站点" && routeResult != {}){
              showRouteResult(routeResult);
            }
          },
        ),
      ),
    );
  }

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
      LogUtils.e("msyydsyydsyyds" + stationList.length.toString());
    }
    // if (Platform.isAndroid) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }
    // 启动本地服务器
    // final server = Jaguar(address: "0.0.0.0", port: 9998);
    // server.addRoute(serveFlutterAssets());
    // await server.serve(logRequests: true);
    // print("本地服务器启动成功！");
    // print('ready in 3...');
    // await Future.delayed(const Duration(seconds: 1));
    // FlutterNativeSplash.remove();
  }

  void modifyInfo() {
    NavigatorUtils.pushPageByFade(context: context, targPage: ModifyInfoPage());
  }

  void showStationOnMap(String station_name) {
    _webViewController
        ?.runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      var station_info = jsonDecode(value);
      station_info = jsonDecode(station_info);
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      if (_scaffoldkey.currentState!.isDrawerOpen) {
        BuildContext? currentContext = _scaffoldkey.currentContext;
        Navigator.pop(currentContext!);
      }
      _webViewController?.runJavascript("touchStation('$station_id')");
    });
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

  void showRouteResult(Map<String, dynamic> routeResult) async {
    return showModalBottomSheet<void>(
      context: context,
      //自定义底部弹窗布局
      shape: new RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2.0,
          child: Column(
            children: [
              // 弹窗标题栏
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.8, color: Colors.grey.shade400))),
                child: ListTile(
                  title: Text(
                    "查询结果",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  trailing: IconButton(
                    padding: EdgeInsets.only(bottom: 1),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 40,
                  ),
                  leading: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.transparent,
                    ),
                    iconSize: 35,
                  ),
                ),
              ),
              // 起点站和终点站的提示信息栏
              Container(
                padding: EdgeInsets.only(left: 20),
                margin: EdgeInsets.only(bottom: 20, top: 15),
                alignment: Alignment.centerLeft,
                child: Text(
                  "从 $_departureStation 至 $_reachStation",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              // 最便宜策略结果展示栏
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: ListTile(
                  horizontalTitleGap: 0,
                  leading: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image(
                          image:
                              AssetImage("assets/images/green_triangle.png"))),
                  title: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 15,
                                  child: Text(
                                    "3",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("4"), Text("元")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("10"), Text("站")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("1"), Text("换")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("33"), Text("分")])),
                              ],
                            ),
                          ))
                    ],
                  ),
                  trailing: IconButton(
                      iconSize: 35,
                      onPressed: () => goToRouteResultPage(routeResult),
                      icon: Icon(Icons.navigate_next)),
                ),
              ),
              // 最快速策略结果展示栏
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: ListTile(
                  horizontalTitleGap: 0,
                  leading: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image(
                          image:
                              AssetImage("assets/images/blue_triangle.png"))),
                  title: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 15,
                                  child: Text(
                                    "1",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 15,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 15,
                                  child: Text(
                                    "3",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("4"), Text("元")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("11"), Text("站")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("1"), Text("换")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("48"), Text("分")])),
                              ],
                            ),
                          ))
                    ],
                  ),
                  trailing: IconButton(
                      iconSize: 35,
                      onPressed: () => goToRouteResultPage(routeResult),
                      icon: Icon(Icons.navigate_next)),
                ),
              ),
              // 最舒适策略结果展示栏
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.8, color: Colors.grey.shade400))),
                margin: EdgeInsets.only(bottom: 15),
                child: ListTile(
                  horizontalTitleGap: 0,
                  leading: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image(
                          image: AssetImage("assets/images/red_triangle.png"))),
                  title: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 15,
                                  child: Text(
                                    "2",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 15,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 15,
                                  child: Text(
                                    "3",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("3"), Text("元")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("8"), Text("站")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("0"), Text("换")])),
                                Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                        children: [Text("53"), Text("分")])),
                              ],
                            ),
                          ))
                    ],
                  ),
                  trailing: IconButton(
                      iconSize: 35,
                      onPressed: () => goToRouteResultPage(routeResult),
                      icon: Icon(Icons.navigate_next)),
                ),
              ),
              // 颜色与对应策略的提示信息
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Container(
                        height: 40,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Image(
                            image: AssetImage(
                                "assets/images/green_triangle.png"))),
                    Container(
                      child: Text("最便宜"),
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                    Container(
                        height: 40,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Image(
                            image:
                                AssetImage("assets/images/blue_triangle.png"))),
                    Container(
                      child: Text("最快速"),
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                    Container(
                        height: 40,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Image(
                            image:
                                AssetImage("assets/images/red_triangle.png"))),
                    Container(
                      child: Text("最舒适"),
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void goToRouteResultPage(Map<String, dynamic> routeResult) {
    NavigatorUtils.pushPageByFade(context: context, targPage: RouteResultPage(routeResult));
  }
}

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
                          fontSize: 18),
                      children: [
                        TextSpan(
                            text: query,
                            style: TextStyle(color: Colors.black, fontSize: 18))
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
              style: TextStyle(fontSize: 18),
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
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.home,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.location_city,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.star,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                      bottom:
                          BorderSide(width: 0.8, color: Colors.grey.shade400))),
              child: ListTile(
                leading: Icon(Icons.subway),
                title: RichText(
                  //富文本
                  text: TextSpan(
                      text: suggestionsList[index].substring(0, query.length),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      children: [
                        TextSpan(
                            text:
                                suggestionsList[index].substring(query.length),
                            style: TextStyle(color: Colors.grey, fontSize: 18))
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
