import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'shared_preferences_utils.dart';

List<String> stationList = [];
List<String> recentList = [];
List<String> addFrequentStations = [];
String userHome = '';
String userCompany = '';
String userCity = '';

//搜索框
class SearchBar extends StatefulWidget {
  // final TextEditingController? textController; //内容
  // final onChanged; //输入监听
  // final onSubmitted; //键盘回车监听
  final String hintText; //提示文本
  final webViewController;
  final ValueSetter<String> stationCallBack;
  // final TextInputType textInputType; //设置键盘弹出时类型

  SearchBar({
    Key? key,
    // this.textController,
    // this.onChanged,
    this.hintText = '请输入内容',
    this.webViewController,
    required this.stationCallBack,
    // this.textInputType = TextInputType.text,
    // this.onSubmitted
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState(
      this.hintText, this.webViewController, this.stationCallBack);
}

class _SearchBarState extends State<SearchBar> {
  // TextEditingController? textController; //内容
  // var onChanged; //输入监听
  // var onSubmitted; //键盘回车监听
  var hintText; // 提示文本
  var webViewController; // html页面控制器
  late String showText; // 搜索栏显示文本
  late WebViewController _webViewController;
  late ValueSetter<String> stationCallBack;

  // late TextInputType textInputType; //设置键盘弹出时类型

  _SearchBarState(
    // this.textController,
    // this.onChanged,
    this.hintText,
    this.webViewController,
    this.stationCallBack,
    // this.textInputType = TextInputType.text,
    // this.onSubmitted
  );

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.0.w), //灰色的一层边框
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0.r)),
      ),
      alignment: Alignment.center,
      // width: 100,
      height: 40.h,
      // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
      padding: EdgeInsets.only(left: 6.w, right: 6.w),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Icon(
                Icons.search,
                color: Colors.blue,
              )),
          Expanded(
              flex: 6,
              child: InkWell(
                child: Text(
                  showText,
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () async {
                  //这里是跳转搜索界面的关键
                  var station_back = await showSearch(
                      context: context, delegate: SearchBarDelegate());
                  print(station_back);
                  if (station_back != null && station_back != '') {
                    setState(() {
                      showText = station_back;
                    });
                    stationCallBack(showText);
                    // showStationOnMap(showText);
                  }
                },
              )),
          Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    showText = hintText;
                  });
                },
              ))
        ],
      ),
    );
  }

  void initialization() async {
    showText = hintText;
    LogUtils.e("msyyds${webViewController.runtimeType.toString()}");
    if (webViewController.runtimeType == WebViewController) {
      _webViewController = webViewController;
    }
    stationList = [];
    var _userCity = await SPUtil.getString("userCity");
    if (_userCity != null) {
      userCity = _userCity;
    }
    if (userCity != '') {
      // 读取已开通地铁的城市列表
      String cityStationsString =
          await rootBundle.loadString("assets/city_stations.json");
      Map<String, dynamic> cityStationsResult = jsonDecode(cityStationsString);
      if (cityStationsResult.containsKey(userCity)) {
        stationList = cityStationsResult[userCity].cast<String>();
      }
    }
    var _addFrequentStations = await SPUtil.getString("addFrequentStations");
    var _userHome = await SPUtil.getString("userHome");
    var _userCompany = await SPUtil.getString("userCompany");
    addFrequentStations = jsonDecode(_addFrequentStations!).cast<String>();
    if (_userHome != null) {
      userHome = _userHome;
    }
    if (_userCompany != null) {
      userCompany = _userCompany;
    }

    print(stationList.length);
    print(userHome);
    print(userCompany);
    print(addFrequentStations);
  }

  void showStationOnMap(String station_name) {
    _webViewController
        .runJavascriptReturningResult("searchStation('$station_name')")
        .then((value) {
      var station_info = jsonDecode(value);
      station_info = jsonDecode(station_info);
      print(station_info["stationList"][0]["id"]);
      var station_id = station_info["stationList"][0]["id"];
      _webViewController.runJavascript("touchStation($station_id)");
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
                          fontSize: 18.sp),
                      children: [
                        TextSpan(
                            text: query,
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.sp))
                      ]),
                ),
                onTap: () {
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
    List<String> userList = [];
    if (userHome != '') {
      userList.add(userHome);
    }
    if (userCompany != '') {
      userList.add(userCompany);
    }
    //判断集合中的字符串是否以搜索框内输入的字符串开头，是则返回true，并将结果以list的方式储存在suggestionsList里
    final suggestionsList = query.isEmpty
        ? (userList + addFrequentStations)
        : stationList.where((input) => input.startsWith(query)).toList();

    return ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, index) {
          if (query.isEmpty && userHome != '' && index == 0) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.home,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
          if (query.isEmpty &&
              ((userCompany != '' && userHome != '' && index == 1) ||
                  (userCompany != '' && userHome == '' && index == 0))) {
            return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.8.w, color: Colors.grey.shade400))),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(
                  Icons.location_city,
                  color: Colors.grey[800],
                ),
                title: Text(
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
          if (query.isEmpty && index >= userList.length) {
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
                  suggestionsList[index],
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(context).pop(suggestionsList[index]);
                },
              ),
            );
          }
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
              Navigator.of(context).pop(suggestionsList[index]);
            },
          );
        });
  }
}
