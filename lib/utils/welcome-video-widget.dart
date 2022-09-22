import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../pages/first-start-page.dart';
import '../pages/home-page.dart';
import 'log-utils.dart';
import 'navigator-utils.dart';
import 'shared-preferences-utils.dart';

//app启动视频
class WelcomeVideoWidget extends StatefulWidget {
  WelcomeVideoWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeVideoWidget> createState() => _WelcomeVideoWidgetState();
}

class _WelcomeVideoWidgetState extends State<WelcomeVideoWidget> {
  //创建视频播放控制器
  late VideoPlayerController _controller;

  initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void goToNewPage() async {
    //初始化sputil
    await SPUtil.init();
    //读取首次启动的标识
    // SPUtil.save("firstStart", false);
    bool? firstStart = await SPUtil.getBool("firstStart");
    LogUtils.e("firstStart $firstStart");
    if (firstStart == null || !firstStart) {
      NavigatorUtils.pushPageByFade(
          context: context, targPage: FirstStartPage(), isReplace: true);
    } else {
      NavigatorUtils.pushPageByFade(
        context: context,
        targPage: HomePage(),
        isReplace: true,
      );
    }
  }

  void initialization() {
    //加载视频资源
    _controller = VideoPlayerController.asset('assets/videos/start_video.mp4')
      ..initialize().then((_) {
        LogUtils.e("视频加载完成");
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.play();
        setState(() {});
      });

    //执行监听，只要有内容就会刷新
    _controller.addListener(() {
      setState(() {
        //当视频播放完毕后，自动跳转页面
        if (_controller.value.position.inSeconds ==
            _controller.value.duration.inSeconds) {
          goToNewPage();
        }
      });
    });
  }
}
