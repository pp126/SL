import 'package:app/common/theme.dart';
import 'package:app/ui/mine/task/exchange_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import 'my_task_page.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final tabs = [
    {'title': Tab(text: '我的任务'), 'page': MyTaskPage()},
    {'title': Tab(text: '兑换道具'), 'page': ExchangePage()}
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(
            tabs.map((e) => e['title']).toList(growable: false)
          ),
        ),
        body: TabBarView(
          children: tabs.map((e) => e['page']).toList(growable: false),
        ),
      ),
    );
  }
}
