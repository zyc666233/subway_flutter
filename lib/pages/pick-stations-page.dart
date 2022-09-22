import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:subway_flutter/utils/log-utils.dart';
import 'package:subway_flutter/utils/navigator-utils.dart';

List<String> stationList = [];
List<String> recentList = [];

class PickStationsPage extends StatefulWidget {
  final String city;
  PickStationsPage({Key? key, required this.city}) : super(key: key);

  @override
  State<PickStationsPage> createState() => _PickStationsPageState(city);
}

class _PickStationsPageState extends State<PickStationsPage> {
  String _city;
  _PickStationsPageState(this._city);

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.grey),
          backgroundColor: Colors.white,
          title: Container(
            height: 35,
            width: MediaQuery.of(context).size.width - 120,
            decoration: BoxDecoration(
                color: Color.fromRGBO(230, 230, 230, 1.0),
                borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Icon(Icons.search, color: Colors.grey)),
                  Text(
                    "点我进行搜索",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
              onTap: () async {
                //这里是跳转搜索界面的关键
                var station_back = await showSearch(
                    context: context, delegate: SearchBarDelegate());
                if (station_back != null) {
                  Navigator.of(context).pop(station_back);
                }
              },
            ),
          ),
        ),
        body: Container(
          child: ListView.builder(
              itemCount: stationList.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 0.8, color: Colors.grey.shade400))),
                  child: ListTile(
                    style: ListTileStyle.list,
                    leading: Icon(Icons.subway),
                    title: Text(
                      stationList[index],
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(stationList[index]);
                    },
                  ),
                );
              }),
        ));
  }

  void initialization() async {
    print(_city);
    stationList = [];
    if (_city != '选择所在城市') {
      // 读取已开通地铁的城市列表
      String cityStationsString =
          await rootBundle.loadString("assets/city-stations.json");
      Map<String, dynamic> cityStationsResult = jsonDecode(cityStationsString);
      if (cityStationsResult.containsKey(_city)) {
        stationList = cityStationsResult[_city].cast<String>();
      }
    }
    setState(() {
      print(stationList.length);
    });
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
                  if (recentList.length >= 10) {
                    recentList.removeLast();
                  }
                  if (!recentList.contains(query)) {
                    recentList.add(query);
                  }
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
    //判断集合中的字符串是否以搜索框内输入的字符串开头，是则返回true，并将结果以list的方式储存在suggestionsList里
    final suggestionsList = query.isEmpty
        ? recentList
        : stationList.where((input) => input.startsWith(query)).toList();

    return ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, index) {
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
              if (recentList.length >= 10) {
                recentList.removeLast();
              }
              if (!recentList.contains(suggestionsList[index])) {
                recentList.add(suggestionsList[index]);
              }
              Navigator.of(context).pop(suggestionsList[index]);
            },
          );
        });
  }
}
