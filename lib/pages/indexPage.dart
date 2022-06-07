import 'package:flutter/material.dart';
import '../config.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IndexPageState();
  }
}

class IndexPageState extends State<IndexPage> {
  //搜索框
  Widget _barSearch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/sub_way_img.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        // Container(
        //   child: Image.asset('images/sub_way_img.png', width: 20, height: 20, fit: BoxFit.cover),
        //   width: 25.0,
        //   height: 25.0,
        // ),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                    left: 5.0, top: 5.0, bottom: 5.0, right: 5.0),
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 5.0),
                      child: const Icon(
                        Icons.search,
                        size: 25.0,
                        color: Colors.grey,
                      ),
                    ),
                    const Text("搜索站点",
                        style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                    color: Config.searchBackgroundColor))),
        const Text("+"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Config.themeData,
      home: Scaffold(
        appBar: AppBar(
          title: _barSearch(), //搜索栏作为该页面的title
        ),
        body: const Center(
          child: Image(image: AssetImage('assets/images/xianlu.png')),
        ),
        floatingActionButton: FloatingActionButton(
          child: Image.asset('assets/images/sub_way_img.png'),
          onPressed: null,
          tooltip: '乘车码',
        ),
      ),
    );
  }
}
