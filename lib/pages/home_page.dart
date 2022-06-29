import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subway_flutter/pages/modify_info_page.dart';
import 'package:subway_flutter/pages/pick_stations_page.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:subway_flutter/utils/navigator_utils.dart';
import 'package:subway_flutter/utils/search_bar_wigdet.dart';
import 'package:subway_flutter/utils/shared_preferences_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';

//公告相关
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
  String _userName = "";
  String _userCity = "";
  String _userHome = "";
  String _userCompany = "";
  String _walkHomeTime = "";
  String _walkCompanyTime = "";
  List<String> _addFrequentStations = [];
  List<String> _addFrequentCities = [];

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
              currentAccountPicture: CircleAvatar(
                backgroundImage: _headImage,
              ),
              accountEmail: Text(
                "所在城市：${_userCity}",
                style: TextStyle(fontSize: 12),
              ),
              accountName: Text(
                _userName,
                style: TextStyle(fontSize: 16),
              ),
              //配置其他
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
                // Container(
                //   padding: EdgeInsets.all(5),
                //   child: Container(
                //       alignment: Alignment.center,
                //       decoration: BoxDecoration(
                //           border: Border.all(color: Colors.white),
                //           borderRadius: BorderRadius.all(Radius.circular(5))),
                //       child: Text("编辑",
                //           style: TextStyle(color: Colors.white, fontSize: 12))),
                // )
              ],
            ),
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
                onTap: () {},
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
                onTap: () {},
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(top: 5, bottom: 5),
            //   decoration: BoxDecoration(
            //       border: Border(
            //           bottom:
            //               BorderSide(width: 0.8, color: Colors.grey.shade400))),
            //   child: ListTile(
            //     leading: CircleAvatar(child: Icon(Icons.star)),
            //     title: Text(
            //       "常去车站：",
            //       style: TextStyle(fontSize: 18),
            //     ),
            //     onTap: () {},
            //   ),
            // ),
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
                              // Navigator.of(context).pop(_addFrequentStations[index]);
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
                        SearchBar(
                          // textController: TextEditingController(),
                          hintText: "出发站点",
                          // onSubmitted: (value) {
                          //   print("$value");
                          // },
                          // onChanged: (value) {
                          //   print("$value");
                          // },
                        ),
                        SearchBar(
                          // textController: TextEditingController(),
                          hintText: "到达站点",
                          // onSubmitted: (value) {
                          //   print("$value");
                          // },
                          // onChanged: (value) {
                          //   print("$value");
                          // },
                        ),
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: null,
          tooltip: '乘车码',
        ),
      ),
    );
  }

  void _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString(_filePath);
    // _webViewController?.loadUrl(Uri.dataFromString(fileHtmlContents,
    //         mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
    //     .toString());
    _webViewController?.loadHtmlString(fileHtmlContents);

    String jsContent = await rootBundle.loadString(_jsPath);
    _webViewController?.runJavascript(jsContent);
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
}
