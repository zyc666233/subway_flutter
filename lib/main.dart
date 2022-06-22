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
      routes: {
        '/root': (context) => HomePage(),
        '/welcome': (context) => WelcomePage(),
      },
      home: const MyHomePage(title: '智慧出行demo'),
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
  // int _currentIndex = 0; //底部导航栏下标
  // final List _pageList = [
  //   const IndexPage(),
  //   const SitePage(),
  //   const Notice(),
  //   const Mine(),
  // ];

  @override
  void initState() {
    super.initState();
    initialization();
    // Future.delayed(Duration.zero, () {
    //   welcome();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WelcomePage()
        //底部导航栏
        // bottomNavigationBar: BottomNavigationBar(
        //   currentIndex: _currentIndex,
        //   type: BottomNavigationBarType.fixed,
        //   iconSize: 30,
        //   onTap: (int index) {
        //     setState(() {
        //       _currentIndex = index;
        //     });
        //   },
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: "首页",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.train),
        //       label: "出行",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.visibility),
        //       label: "通知",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.people_alt),
        //       label: "我的",
        //     ),
        //   ],
        // ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.add),
        // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
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

  // void welcome() {
  //   NavigatorUtils.pushPageByFade(
  //       context: context, targPage: WelcomePage(), isReplace: true);
  //   // Navigator.pushReplacementNamed(context, '/welcome');
  // }
}
