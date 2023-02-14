import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/home/common/banner_view.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/moment/moment_sub_item.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import 'home_meet_chitchat_view.dart';
import 'home_meet_fresh_view.dart';
import 'home_meet_noob_view.dart';

class HomeMeetView extends StatefulWidget {
  @override
  _HomeMeetViewState createState() => _HomeMeetViewState();
}

class _HomeMeetViewState extends State<HomeMeetView> {
  final tabs = [
    {'tab': '连麦聊', 'page': HomeMeetChitchatView()},
   {'tab': '新动态', 'page': MomentSubItem(type: 2,)},
    {'tab': '迎萌新', 'page': HomeMeetNoobView()},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: BannerView()),
            SliverPadding(padding: EdgeInsets.only(top: 14)),
            SliverPersistentHeader(
              delegate: TabBarPersistentHeaderDelegate(
                Material(
                  child: xAppBar$TabBar(
                    tabs.map<Widget>((e) => Text(e['tab'])).toList(growable: false),
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                44,
              ),
            ),
          ];
        },
        body: TabBarView(children: tabs.map<Widget>((e) => e['page']).toList(growable: false)),
      ),
    );
  }
}
