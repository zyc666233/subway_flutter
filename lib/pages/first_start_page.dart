import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subway_flutter/pages/home_page.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:subway_flutter/utils/navigator_utils.dart';
import 'package:subway_flutter/utils/shared_preferences_utils.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';

import 'pick_stations_page.dart';

class FirstStartPage extends StatefulWidget {
  FirstStartPage({Key? key}) : super(key: key);

  @override
  State<FirstStartPage> createState() => _FirstStartPageState();
}

class _FirstStartPageState extends State<FirstStartPage> {
  // 键盘焦点控制
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _walkHomeFocusNode = FocusNode();
  final FocusNode _walkCompanyFocusNode = FocusNode();
  // 键盘开启状态监听
  late StreamSubscription<bool> _keyboardSubscription;
  // 输入框控制器
  final _nameController = TextEditingController();
  final _walkHomeController = TextEditingController();
  final _walkCompanyController = TextEditingController();
  // 图片选择器
  final ImagePicker _picker = ImagePicker();
  var _image = null;
  var _headImage = null;
  // 用户选择城市和地铁站
  String _city = '选择所在城市'; // 用户所在城市
  String _home = '家附近的车站'; // 用户家附近的车站
  String _company = '公司附近车站'; // 用户公司附近车站
  Map<String, List<String>> _subwayCities = {}; // 已开通地铁的“省份-城市列表”
  List<String> _cities = []; // 已开通地铁的城市列表
  List<String> _stations = []; // 所选城市的地铁站列表
  List<String> _addFrequentCities = []; // 用户添加的常去城市列表
  List<String> _addFrequentStations = []; // 用户添加的常去地铁站列表

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
        child: KeyboardDismissOnTap(
          dismissOnCapturedTaps: true,
          child: Column(
            children: [
              //欢迎文字
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "欢迎",
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "感谢您的使用，首次登录可完善资料以体验全部功能",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              //头像组件
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 5),
                child: CircleAvatar(
                  radius: 61,
                  backgroundColor: Colors.black,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(60.0)),
                    onTap: () => addImage(),
                    child: CircleAvatar(
                      foregroundImage: _headImage,
                      backgroundColor: Colors.white,
                      radius: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 45,
                            color: Colors.blue,
                          ),
                          Text(
                            "头像",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //输入昵称
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: TextField(
                  maxLength: 10,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      hintText: "请输入昵称",
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10)),
                  focusNode: _nameFocusNode,
                  controller: _nameController,
                ),
              ),
              //跳转按钮
              TextButton(
                onPressed: () {
                  if (_city == "选择所在城市" || _city == '') {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('提示'),
                              content: Text(('请先选择所在城市！')),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("确定"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ));
                  } else {
                    goToHomePage();
                  }
                },
                child: Text(
                  "开始使用，稍后再填",
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                  // 文本颜色
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 15)),
                  // 前景色
                  foregroundColor: MaterialStateProperty.resolveWith(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        //按下时的颜色
                        return Colors.grey[800];
                      }
                      //默认状态使用白色
                      return Colors.white;
                    },
                  ),
                  // 按钮背景色
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    //设置按下时的背景颜色
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blue[400];
                    }
                    //默认背景颜色
                    return Colors.blue[200];
                  }),
                ),
              ),
              // 填写城市
              Container(
                padding: EdgeInsets.only(top: 20, left: 50, right: 80),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          color: Colors.grey[700],
                          onPressed: () => pickCity(),
                          icon: Icon(Icons.location_on),
                          iconSize: 30,
                        )),
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 10),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.8,
                                      color: Colors.grey.shade400))),
                          child: Text(
                            _city,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 填写家附近站点信息
              Container(
                padding: EdgeInsets.only(top: 20, left: 35, right: 45),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: IconButton(
                            onPressed: () => pickStations("home"),
                            icon: Icon(Icons.home),
                            iconSize: 30,
                            color: Colors.grey[700],
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        flex: 4,
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Container(
                            padding: EdgeInsets.only(bottom: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 0.8,
                                        color: Colors.grey.shade400))),
                            child: Text(
                              _home,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 15),
                            ),
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "步行时长",
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        focusNode: _walkHomeFocusNode,
                        controller: _walkHomeController,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 22),
                          child: Text(
                            '分钟',
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                  ],
                ),
              ),
              // 填写公司附近站点信息
              Container(
                padding: EdgeInsets.only(top: 20, left: 35, right: 45),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: IconButton(
                            onPressed: () => pickStations("company"),
                            icon: Icon(Icons.location_city),
                            iconSize: 30,
                            color: Colors.grey[700],
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.8,
                                      color: Colors.grey.shade400))),
                          child: Text(
                            _company,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "步行时长",
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        focusNode: _walkCompanyFocusNode,
                        controller: _walkCompanyController,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 22),
                          child: Text(
                            '分钟',
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                  ],
                ),
              ),
              // 添加常去车站
              Container(
                padding: EdgeInsets.only(left: 40, right: 40, top: 15),
                child: TextButton(
                  onPressed: () {
                    // NavigatorUtils.pushPage(context: context, targPage: AddFrequentCities());
                    _showMultiSelectStations();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      Text(
                        "添加常去车站",
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                        BorderSide(color: Colors.black)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                    // 文本颜色
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 15)),
                    // 前景色
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    // 按钮背景色
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
              // 添加常去城市
              Container(
                padding: EdgeInsets.only(left: 40, right: 40, top: 15),
                child: TextButton(
                  onPressed: () => _showMultiSelectCities(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      Text(
                        "添加常去城市",
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                        BorderSide(color: Colors.black)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                    // 文本颜色
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 15)),
                    // 前景色
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    // 按钮背景色
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void pickStations(String type) {
    if (_city == '选择所在城市') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('提示'),
                content: Text(('请先选择所在城市！')),
                actions: <Widget>[
                  TextButton(
                    child: Text("确定"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
    } else {
      NavigatorUtils.pushPage(
          context: context,
          targPage: PickStationsPage(
            city: _city,
          ),
          dismissCallBack: (value) {
            if (value != null && value != '') {
              if (type == 'home') {
                setState(() {
                  _home = value;
                });
              } else if (type == 'company') {
                setState(() {
                  _company = value;
                });
              }
            }
          });
    }
  }

  // 添加头像
  void addImage() async {
    LogUtils.e("点击了头像");
    // 让用户从相册中选择图片
    _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (_image != null) {
        _headImage = FileImage(File(_image.path));
      }
    });
  }

  // 页面初始化
  void initialization() async {
    // 监听软键盘状态初始化
    var _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((bool visible) {
      print('键盘是否打开: $visible');
      if (!visible) {
        _nameFocusNode.unfocus();
        _walkHomeFocusNode.unfocus();
        _walkCompanyFocusNode.unfocus();
      }
    });
    // 初始化本地存储工具
    await SPUtil.init();
    // 读取已开通地铁的城市列表
    String provinceCitysString =
        await rootBundle.loadString("assets/provinces_citys.json");
    String subwayCitysString =
        await rootBundle.loadString("assets/subway_citys.json");
    Map<String, dynamic> provinceCitysResult = jsonDecode(provinceCitysString);
    Map<String, dynamic> subwayCitysResult = jsonDecode(subwayCitysString);
    subwayCitysResult.forEach((key, value) {
      String provinceCode = key.substring(0, 2) + '0000';
      String province = provinceCitysResult['86'][provinceCode];
      if (!_subwayCities.containsKey(province)) {
        _subwayCities[province] = [];
      }
      _subwayCities[province]?.add(value['name']);
      if (!_cities.contains(value['name'])) {
        _cities.add(value['name']);
      }
    });
  }

  // 执行跳转到地图页面的工作
  void goToHomePage() async {
    // 保存用户填写的信息到本地
    if (_nameController.text != "") {
      LogUtils.e(_nameController.text);
      SPUtil.save("userName", _nameController.text);
    }
    if (_city != "" && _city != '选择所在城市') {
      LogUtils.e(_city);
      SPUtil.save("userCity", _city);
    }
    if (_home != "" && _home != '家附近的车站') {
      LogUtils.e(_home);
      SPUtil.save("userHome", _home);
    }
    if (_company != "" && _company != '公司附近车站') {
      LogUtils.e(_company);
      SPUtil.save("userCompany", _company);
    }
    if (_walkHomeController.text != "") {
      LogUtils.e(_walkHomeController.text);
      SPUtil.save("walkHomeTime", "${_walkHomeController.text} min");
    }
    if (_walkCompanyController.text != "") {
      LogUtils.e(_walkCompanyController.text);
      SPUtil.save("walkCompanyTime", "${_walkCompanyController.text} min");
    }
    // 将用户选择的头像保存到应用缓存目录
    if (_image != null) {
      // Directory tempDir = await getTemporaryDirectory();
      // String tempPath = tempDir.path;
      File touxiang = File(_image.path);
      // var touxiangBytes = await _image.readAsBytes();
      // List<int> list = new List.from(touxiangBytes);
      // touxiang.writeAsBytesSync(list);
      SPUtil.save("avatarImagePath", touxiang.path);
    }
    // 保存常去车站列表
    LogUtils.e(jsonEncode(_addFrequentStations));
    SPUtil.save("addFrequentStations", "${jsonEncode(_addFrequentStations)}");
    // 保存常去城市列表
    LogUtils.e(jsonEncode(_addFrequentCities));
    SPUtil.save("addFrequentCities", "${jsonEncode(_addFrequentCities)}");
    // 执行页面跳转
    SPUtil.save("firstStart", true);
    NavigatorUtils.pushPageByFade(
        context: context, targPage: HomePage(), isReplace: true);
  }

  // 选择所在城市
  void pickCity() {
    Pickers.showMultiLinkPicker(context,
        data: _subwayCities,
        selectData: ['上海市', '上海市'],
        columeNum: 2,
        pickerStyle: PickerStyle(pickerHeight: 320),
        onConfirm: (List p, List<int> position) {
      setState(() {
        _city = p[1];
      });
      // print('longer >>> 返回数据：${p.join('、')}');
      // print('longer >>> 返回数据下标：${position.join('、')}');
      // print('longer >>> 返回数据类型：${p.map((x) => x.runtimeType).toList()}');
    });
  }

  // 添加常去城市
  void _showMultiSelectCities() async {
    await showDialog(
      // isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          // initialChildSize: 0.6,
          // maxChildSize: 0.8,
          // minChildSize: 0.2,
          items: _cities.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: _addFrequentCities,
          onConfirm: (values) {
            if (values.length > 5) {
              _addFrequentCities = [];
              for (var i = 0; i < 5; i++) {
                _addFrequentCities.add(values[i].toString());
              }
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('提示'),
                        content: Text(('最多添加五个城市')),
                        actions: <Widget>[
                          TextButton(
                            child: new Text("确定"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showMultiSelectCities();
                            },
                          ),
                        ],
                      ));
            } else {
              _addFrequentCities = [];
              for (var item in values) {
                _addFrequentCities.add(item.toString());
              }
              // print(_addFrequentCities);
            }
          },
          searchable: true,
          searchHint: "搜索城市",
          cancelText: Text("取消", style: TextStyle(fontSize: 18)),
          confirmText: Text("确认", style: TextStyle(fontSize: 18)),
          listType: MultiSelectListType.LIST,
          selectedColor: Colors.blue[300],
          title: Text("添加城市"),
        );
      },
    );
  }

  // 添加常去车站
  void _showMultiSelectStations() async {
    _stations = [];
    if (_city != '选择所在城市') {
      // 读取已开通地铁的城市列表
      String cityStationsString =
          await rootBundle.loadString("assets/city_stations.json");
      Map<String, dynamic> cityStationsResult = jsonDecode(cityStationsString);
      if (cityStationsResult.containsKey(_city)) {
        _stations = cityStationsResult[_city].cast<String>();
      }
    }
    await showDialog(
      // isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          // initialChildSize: 0.6,
          // maxChildSize: 0.8,
          // minChildSize: 0.2,
          items: _stations.map((e) => MultiSelectItem(e, e)).toList(),
          initialValue: _addFrequentStations,
          onConfirm: (values) {
            if (values.length > 5) {
              _addFrequentStations = [];
              for (var i = 0; i < 5; i++) {
                _addFrequentStations.add(values[i].toString());
              }
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('提示'),
                        content: Text(('最多添加五个站点')),
                        actions: <Widget>[
                          TextButton(
                            child: new Text("确定"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showMultiSelectStations();
                            },
                          ),
                        ],
                      ));
            } else {
              _addFrequentStations = [];
              for (var item in values) {
                if (!_addFrequentCities.contains(item.toString())){
                  _addFrequentStations.add(item.toString());
                }
              }
              print(_addFrequentCities);
            }
          },
          searchable: true,
          searchHint: "搜索地铁站",
          cancelText: Text("取消", style: TextStyle(fontSize: 18)),
          confirmText: Text("确认", style: TextStyle(fontSize: 18)),
          listType: MultiSelectListType.LIST,
          selectedColor: Colors.blue[300],
          title: Text("添加地铁站"),
        );
      },
    );
  }
}
