import 'package:flutter/material.dart';

class SitePage extends StatefulWidget {
  const SitePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SitePageState();
  }
}

class SitePageState extends State<SitePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('暂无站点',
          style: TextStyle(fontSize: 15.0, color: Colors.green)),
    );
  }
}
