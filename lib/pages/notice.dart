import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subway_flutter/utils/search_bar_wigdet.dart';
import 'package:webview_flutter/webview_flutter.dart';

//公告相关
class Notice extends StatefulWidget {
  const Notice({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoticePageState();
  }
}

class NoticePageState extends State<Notice> {
  String filePath = "assets/files/subway_map_test.html";
  String jsPath = 'assets/files/adcode.js';
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: Config.themeData,
      home: Scaffold(
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
              top: 15,
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
                        onPressed: (){},
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
    String fileHtmlContents = await rootBundle.loadString(filePath);
    // _webViewController?.loadUrl(Uri.dataFromString(fileHtmlContents,
    //         mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
    //     .toString());
    _webViewController?.loadHtmlString(fileHtmlContents);

    String jsContent = await rootBundle.loadString(jsPath);
    _webViewController?.runJavascript(jsContent);
  }
}
