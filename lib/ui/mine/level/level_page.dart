import 'package:app/widgets.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

import 'level_charm_page.dart';
import 'level_suffer_page.dart';
import 'level_wealth_page.dart';

class LevelPage extends StatefulWidget {
  @override
  _LevelPageState createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final tabs = [
    {'title': Tab(text: '财富等级'), 'page': LevelWealthPage()},
    {'title': Tab(text: '魅力等级'), 'page': LevelCharmPage()},
    {'title': Tab(text: '经验等级'), 'page': LevelSufferPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(tabs.map((e) => e['title']).toList(growable: false)),
        ),
        body: TabBarView(
          children: tabs.map((e) => e['page']).toList(growable: false),
        ),
      ),
    );
  }
}
