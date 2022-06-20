import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subway_flutter/pages/homePage.dart';

import 'log_utils.dart';
import 'navigator_utils.dart';

class WelcomeTimeWidget extends StatefulWidget {
  @override
  _WelcomeTimeWidgetState createState() => _WelcomeTimeWidgetState();
}

class _WelcomeTimeWidgetState extends State<WelcomeTimeWidget> {
  int currentTime = 8;

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    //创建计时器 间隔1秒执行
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentTime == 0) {
        //停止计时 去首页面
        _timer.cancel();
        goHome();
        return;
      }

      currentTime--;
      setState(() {});
      // 每间隔1秒回调一下
      LogUtils.e("计时器回调");
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        goHome();
      },
      child: buildContainer(),
    );
  }

  Container buildContainer() {
    return Container(
      decoration: BoxDecoration(
          //边框样式设置
          border: Border.all(color: Colors.white, width: 2),
          //边框圆角设置
          borderRadius: BorderRadius.all(Radius.circular(20))),
      //子Widget 居中
      alignment: Alignment.center,
      child: Text(
        "${currentTime}s",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      width: 100,
      height: 33,
    );
  }

  void goHome() {
    LogUtils.e("计时完成去首页面");
    NavigatorUtils.pushPageByFade(
      context: context,
      targPage: HomePage(),
      isReplace: true,
    );
  }
}
