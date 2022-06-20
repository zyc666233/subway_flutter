import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            Row(
              children: [
                Expanded(
                    child: UserAccountsDrawerHeader(
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
                ))
              ],
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.home)),
              title: Text(
                _userHome,
                style: TextStyle(fontSize: 18),
              ),
              trailing: Text(
                "步行时长：${_walkHomeTime}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.business)),
              title: Text(
                _userCompany,
                style: TextStyle(fontSize: 18),
              ),
              trailing: Text(
                "步行时长：${_walkHomeTime}",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Divider(
              color: Colors.black,
            )
          ]),
        ),
        body: Stack(
          children: [
            //第一层，地铁图
            Positioned.fill(
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

            //第二层，搜索栏
            Positioned(
              left: 5,
              right: 5,
              top: 40,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromARGB(255, 245, 245, 245),
                      width: 0.0), //灰色的一层边框
                  color: Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
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
                            textController: TextEditingController(),
                            hintText: "出发站点",
                            onSubmitted: (value) {
                              print("$value");
                            },
                            onChanged: (value) {
                              print("$value");
                            },
                          ),
                          SearchBar(
                            textController: TextEditingController(),
                            hintText: "到达站点",
                            onSubmitted: (value) {
                              print("$value");
                            },
                            onChanged: (value) {
                              print("$value");
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
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
    setState(() {
      _headImage = FileImage(File(_imagePath));
    });

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
}
