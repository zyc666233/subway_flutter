import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        body: WebView(
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
        ),
        floatingActionButton: FloatingActionButton(
          child: Image.asset('assets/images/sub_way_img.png'),
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
