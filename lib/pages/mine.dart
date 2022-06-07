import 'package:flutter/material.dart';

class Mine extends StatefulWidget {
  const Mine({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MinePageState();
  }
}

class MinePageState extends State<Mine> {
  Widget _header() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                top: 60.0, left: 20.0, bottom: 10.0, right: 20.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  child: Image.asset('assets/images/touxiang.png'),
                  radius: 40.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text("150****1111"),
                        Text("青铜会员"),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.assignment,
                        size: 18.0,
                        color: Colors.green,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        child: const Text("签到",
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.green)),
                      ),
                    ],
                  ),
                )
              ],
            ),
            decoration: const BoxDecoration(color: Colors.green),
          ),
          Container(
              decoration: const BoxDecoration(color: Colors.green),
              padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      const Text(
                        '10',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: const Text('积分',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.0)),
                      )
                    ],
                  )),
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      const Text(
                        '234.4',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: const Text('里程(km)',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.0)),
                      )
                    ],
                  ))
                ],
              )),
        ],
      ),
    );
  }

  //内容
  Widget _contentView() {
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
            child: Opacity(
                opacity: 1.0,
                child: Container(
                  height: 80.0,
                  color: Colors.green,
                )),
          ),
          Align(
            child: Container(
              margin: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  bottom: BorderSide(color: Colors.black12))),
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
                        height: 60.0,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child:
                                    const Icon(Icons.access_time, size: 20.0),
                                margin: const EdgeInsets.only(right: 12.0),
                              ),
                              const Expanded(
                                  child: Text("我的收藏",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.0))),
                              Container(
                                  child: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ))
                            ],
                          ),
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
//                                  bottom:
//                                      new BorderSide(color: Colors.black12)
                                  )),
                        )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            children: <Widget>[
              _header(),
              _contentView(),
            ],
          ),
        ),
      )),
    );
  }
}
