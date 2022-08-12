import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:subway_flutter/utils/navigator_utils.dart';
import 'package:subway_flutter/pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());

  // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: '智慧出行demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // routes: {
      //   '/root': (context) => HomePage(),
      //   '/welcome': (context) => WelcomePage(),
      // },
      home: const MyHomePage(title: 'subway_flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WelcomePage());
  }

  void initialization() async {
    // 启动本地服务器
    final server = Jaguar(address: "0.0.0.0", port: 9998);
    server.addRoute(serveFlutterAssets());
    await server.serve(logRequests: true);
    LogUtils.e("本地服务器启动成功！");
    // print('ready in 3...');
    // await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }
}
