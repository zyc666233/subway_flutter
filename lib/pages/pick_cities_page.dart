import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/shared_preferences_utils.dart';

List<String> cities = [];
List<String> recentList = [];
List<String> addFrequentCities = [];

class PickCitiesPage extends StatefulWidget {
  PickCitiesPage({Key? key}) : super(key: key);

  @override
  State<PickCitiesPage> createState() => _PickCitiesPageState();
}

class _PickCitiesPageState extends State<PickCitiesPage> {
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
          height: 35.h,
          width: MediaQuery.of(context).size.width.w - 120.w,
          decoration: BoxDecoration(
              color: Color.fromRGBO(230, 230, 230, 1.0),
              borderRadius: BorderRadius.circular(20.r)),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: Icon(Icons.search, color: Colors.grey)),
                Text(
                  "点我进行搜索",
                  style: TextStyle(color: Colors.grey, fontSize: 15.sp),
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
      body: ListView.builder(
          itemCount: addFrequentCities.length + cities.length,
          itemBuilder: (context, index) {
            if (index < addFrequentCities.length) {
              return Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.8.w, color: Colors.grey.shade400))),
                child: ListTile(
                  style: ListTileStyle.list,
                  leading: Icon(
                    Icons.star,
                    color: Colors.grey[800],
                  ),
                  title: Text(
                    addFrequentCities[index],
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(addFrequentCities[index]);
                  },
                ),
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.8.w, color: Colors.grey.shade400))),
                child: ListTile(
                  style: ListTileStyle.list,
                  leading: Icon(Icons.location_on),
                  title: Text(
                    cities[index - addFrequentCities.length],
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pop(cities[index - addFrequentCities.length]);
                  },
                ),
              );
            }
          }),
    );
  }

  void initialization() async {
    cities = [];
    String subwayCitysString =
        await rootBundle.loadString("assets/subway_citys.json");
    Map<String, dynamic> subwayCitysResult = jsonDecode(subwayCitysString);
    subwayCitysResult.forEach((key, value) {
      if (!cities.contains(value['name'])) {
        cities.add(value['name']);
      }
    });
    var _addFrequentCities = await SPUtil.getString("addFrequentCities");
    addFrequentCities = jsonDecode(_addFrequentCities!).cast<String>();
    setState(() {
      print(cities.length);
      print(addFrequentCities);
    });
  }
}

class SearchBarDelegate extends SearchDelegate<String> {
  String get searchFieldLabel => "搜索城市";

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
    if (cities.contains(query)) {
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
                          fontSize: 18.sp),
                      children: [
                        TextSpan(
                            text: query,
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.sp))
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
              style: TextStyle(fontSize: 18.sp),
            ),
          );
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    //判断集合中的字符串是否以搜索框内输入的字符串开头，是则返回true，并将结果以list的方式储存在suggestionsList里
    final suggestionsList = query.isEmpty
        ? recentList
        : cities.where((input) => input.startsWith(query)).toList();

    return ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                leading: Icon(Icons.subway),
                title: RichText(
                  //富文本
                  text: TextSpan(
                      text: suggestionsList[index].substring(0, query.length),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp),
                      children: [
                        TextSpan(
                            text:
                                suggestionsList[index].substring(query.length),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 18.sp))
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
