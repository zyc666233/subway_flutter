import 'package:flutter/material.dart';
import 'package:subway_flutter/utils/welcome_time_widget.dart';
import 'package:subway_flutter/utils/welcome_video_widget.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 第一层，图片或视频
            Positioned.fill(child: WelcomeVideoWidget()),
            // 第二层，倒计时功能
            // Positioned(
            //   child: WelcomeTimeWidget(),
            //   right: 20,
            //   bottom: 60,
            // )
          ],
        ),
      ),
    );
  }
}
