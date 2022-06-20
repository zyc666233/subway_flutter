import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subway_flutter/pages/homePage.dart';
import 'package:subway_flutter/utils/log_utils.dart';
import 'package:subway_flutter/utils/navigator_utils.dart';
import 'package:subway_flutter/utils/shared_preferences_utils.dart';

class FirstStartPage extends StatefulWidget {
  FirstStartPage({Key? key}) : super(key: key);

  @override
  State<FirstStartPage> createState() => _FirstStartPageState();
}

class _FirstStartPageState extends State<FirstStartPage> {
  // 键盘焦点控制
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _homeFocusNode = FocusNode();
  final FocusNode _companyFocusNode = FocusNode();
  final FocusNode _walkHomeFocusNode = FocusNode();
  final FocusNode _walkCompanyFocusNode = FocusNode();
  // 键盘开启状态监听
  late StreamSubscription<bool> _keyboardSubscription;
  // 输入框控制器
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _homeController = TextEditingController();
  final _companyController = TextEditingController();
  final _walkHomeController = TextEditingController();
  final _walkCompanyController = TextEditingController();
  // 图片选择器
  final ImagePicker _picker = ImagePicker();
  var _image = null;
  var _headImage = null;

  @override
  void initState() {
    super.initState();
    initialization();
  }

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
                onPressed: () => goToHomePage(),
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
                padding: EdgeInsets.only(top: 20, left: 50, right: 100),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.location_on),
                          iconSize: 30,
                        )),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        maxLength: 6,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "所在城市",
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        focusNode: _cityFocusNode,
                        controller: _cityController,
                      ),
                    )
                  ],
                ),
              ),
              // 填写家附近站点信息
              Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 50),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.home),
                          iconSize: 30,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        maxLength: 6,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "家附近的车站",
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        focusNode: _homeFocusNode,
                        controller: _homeController,
                      ),
                    ),
                    SizedBox(
                      width: 20,
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
                padding: EdgeInsets.only(top: 20, left: 20, right: 50),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.location_city),
                          iconSize: 30,
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        maxLength: 6,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            hintText: "公司附近车站",
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        focusNode: _companyFocusNode,
                        controller: _companyController,
                      ),
                    ),
                    SizedBox(
                      width: 20,
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
                  onPressed: () {},
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
                  onPressed: () {},
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

  void initialization() async {
    // 初始化本地存储工具
    await SPUtil.init();
    // // 读取应用缓存目录中保存的用户头像
    // String? touxiang = await SPUtil.getString("avatarImagePath");
    // if (touxiang != null) {
    //   LogUtils.e(touxiang);
    //   setState(() {
    //     _headImage = FileImage(File(touxiang));
    //   });
    // }
    // 监听软键盘状态初始化
    var _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((bool visible) {
      print('键盘是否打开: $visible');
      if (!visible) {
        _nameFocusNode.unfocus();
        _cityFocusNode.unfocus();
        _homeFocusNode.unfocus();
        _companyFocusNode.unfocus();
        _walkHomeFocusNode.unfocus();
        _walkCompanyFocusNode.unfocus();
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
    if (_cityController.text != "") {
      LogUtils.e(_cityController.text);
      SPUtil.save("userCity", _cityController.text);
    }
    if (_homeController.text != "") {
      LogUtils.e(_homeController.text);
      SPUtil.save("userHome", _homeController.text);
    }
    if (_companyController.text != "") {
      LogUtils.e(_companyController.text);
      SPUtil.save("userCompany", _companyController.text);
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
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File touxiang = File('$tempPath/avatar.png');
      var touxiangBytes = await _image.readAsBytes();
      List<int> list = new List.from(touxiangBytes);
      touxiang.writeAsBytesSync(list);
      SPUtil.save("avatarImagePath", touxiang.path);
    }
    // 执行页面跳转
    SPUtil.save("firstStart", true);
    NavigatorUtils.pushPageByFade(
        context: context, targPage: HomePage(), isReplace: true);
  }
}
