import 'package:app/ui/home/rank/rank_gift_page.dart';
import 'package:app/ui/home/rank/rank_room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

import 'rank_tab_page.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  final tabs = [
    {'title': Tab(text: '财富榜'), 'page': RankTabPage('2')},
    {'title': Tab(text: '魅力榜'), 'page': RankTabPage('1')},
    {'title': Tab(text: '礼物榜'), 'page': RankGiftPage()},
    {'title': Tab(text: '房间榜'), 'page': RankRoomPage()},
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
