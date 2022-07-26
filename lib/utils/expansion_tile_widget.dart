import 'package:flutter/material.dart';
 
///自定义的listTitle,支持自定义标题栏布局
const Duration _kExpand = Duration(milliseconds: 200);
 
// 分割线显示时机
enum DividerDisplayTime {
  always, //总是显示
  opened, //展开时显示
  closed, //关闭时显示
  never //不显示
}
 
class UserExpansionTile extends StatefulWidget {
  const UserExpansionTile({
    Key? key,
    required this.title,  // title组件，没有任何多余属性，完全自定义
    this.dividerColor,
    this.dividerDisplayTime,  // 分割线显示时机
    this.onExpansionChanged,  // 伸缩状态改变的回调函数
    this.children = const <Widget>[], // 子组件列表
    this.initiallyExpanded = false,   // 初始状态是否展开
  })  : assert(initiallyExpanded != null),
        super(key: key);
 
 
  final Widget title;
 
  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;
 
  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;
 
  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool? initiallyExpanded;
 
  final Color? dividerColor;
 
  final DividerDisplayTime? dividerDisplayTime;

 
  @override
  _UserExpansionTileState createState() => _UserExpansionTileState();
}
 
class _UserExpansionTileState extends State<UserExpansionTile>
    with SingleTickerProviderStateMixin {
  // static final Animatable<double> _easeOutTween =
  //     CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  // static final Animatable<double> _halfTween =
  //     Tween<double>(begin: 0.0, end: 0.5);
 
  final ColorTween _borderColorTween = ColorTween();
  // final ColorTween _headerColorTween = ColorTween();
  // final ColorTween _iconColorTween = ColorTween();
  // final ColorTween _backgroundColorTween = ColorTween();
 
  late AnimationController _controller;
  // late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  // late Animation<Color?> _borderColor;
  // late Animation<Color?> _headerColor;
  // late Animation<Color?> _iconColor;
  // late Animation<Color?> _backgroundColor;
 
  bool _isExpanded = false;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    // _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    // _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    // _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    // _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    // _backgroundColor =
    //     _controller.drive(_backgroundColorTween.chain(_easeOutTween));
    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged!(_isExpanded);
  }
 
  Widget _buildChildren(BuildContext context, Widget? child) {
    // final Color borderSideColor = _borderColor.value ?? Colors.transparent;
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.transparent,
        // border: Border(
        //   bottom: BorderSide(color: borderSideColor),
        // ),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: Column(
        children:[
          GestureDetector(
            child:   widget.title,
            onTap: _handleTap,
          ),
 
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
 
  @override
  void didChangeDependencies() {
    setupDidvierColorTween();
 
    // setupIconColorTween();
 
    // setupBackgroundColor();
 
    super.didChangeDependencies();
  }
 
  void setupDidvierColorTween() {
    final ThemeData theme = Theme.of(context);
 
    Color beginColor = this.widget.dividerColor ?? theme.dividerColor;
    Color endColor = beginColor;
 
    switch (widget.dividerDisplayTime) {
      case DividerDisplayTime.always:
        break;
      case DividerDisplayTime.opened:
        endColor = Colors.transparent;
        break;
      case DividerDisplayTime.closed:
        beginColor = Colors.transparent;
        break;
      case DividerDisplayTime.never:
        beginColor = Colors.transparent;
        endColor = Colors.transparent;
        break;
      default:
    }
    _borderColorTween
      ..begin = beginColor
      ..end = endColor;
  }
 
  // void setupIconColorTween() {
  //   final ThemeData theme = Theme.of(context);
 
  //   Color beginColor = this.widget.iconColor ?? theme.unselectedWidgetColor;
  //   Color endColor = beginColor;
 
  //   _iconColorTween
  //     ..begin = beginColor
  //     ..end = endColor;
  // }
 
  // void setupBackgroundColor() {
  //   _backgroundColorTween
  //     ..begin = widget.backgroundColor
  //     ..end = widget.backgroundColor;
  // }
 
  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}