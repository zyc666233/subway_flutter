import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

//搜索框
class SearchBar extends StatelessWidget {
  final TextEditingController? textController; //内容
  final onChanged; //输入监听
  final onSubmitted; //键盘回车监听
  final hintText; //提示文本
  final TextInputType textInputType; //设置键盘弹出时类型

  SearchBar(
      {this.textController,
      this.onChanged,
      this.hintText = '请输入内容',
      this.textInputType = TextInputType.text,
      this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.0), //灰色的一层边框
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      alignment: Alignment.center,
      // width: 100,
      height: 40,
      // margin: EdgeInsets.fromLTRB(24, 9, 9, 12),
      padding: EdgeInsets.only(left: 6, right: 6),
      child: TextField(
        controller: textController,
        maxLines: 1,
        focusNode: FocusNode(),
        autofocus: false,
        cursorColor: Colors.blue,
        onChanged: onChanged ??
            (value) {
              print("正在输入内容：$value");
            },
        onSubmitted: onSubmitted ??
            (text) {
              print('submit $text');
            },
        keyboardType: textInputType,
        textAlignVertical: TextAlignVertical.center, //添加图标后会有一个小的向上偏移
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: -13), //内容内边距，影响高度
            hintText: hintText,
            border: InputBorder.none,
            isCollapsed: true, //相当于高度包裹的意思，必须设置为true，不然有默认奇妙的最小高度
            fillColor: Colors.white, //背景颜色，必须结合filled: true,才有效
            filled: true, //必须设置为true，fillColor才有效
            isDense: true,
            icon: Padding(
              padding: EdgeInsets.only(left: 3),
              child: Icon(
                Icons.search,
                size: 22,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                //addPostFrameCallback是 StatefulWidge 渲染结束的回调，只会被调用一次
                SchedulerBinding.instance!.addPostFrameCallback((_) {
                  textController!.text = "";
                });
              },
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Icon(
                  Icons.close,
                  size: 23,
                ),
              ),
            )),
      ),
    );
  }
}