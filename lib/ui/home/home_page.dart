import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/auction/auction_page.dart';
import 'package:app/ui/home/index/home_index_follow_view.dart';
import 'package:app/ui/home/rank/rank_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/custom_indicator.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;
import 'package:tuple/tuple.dart';

import 'index/home_index_view.dart';
import 'meet/home_meet_view.dart';
import 'search/search_button.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabs = {
    '首页': HomeIndexView(),
    '遇见': HomeMeetView(),
    '关注': HomeIndexFollowView(),
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: xAppBar(
          xAppBar$TabBar(
            tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
            alignment: Alignment.bottomLeft,
            labelColor: AppPalette.dark,
            labelStyle: Tuple2(TextStyle(fontWeight: fw$SemiBold, fontSize: 18), TextStyle(fontSize: 18)),
            indicator: APPTabIndicator(),
          ),
          action: [
            //todo 隐藏拍卖行
            // 'ic_拍卖行'.toImgActionBtn(onPressed: () => Get.to(AuctionPage())),
            'home/rank'.toSvgActionBtn(onPressed: () => Get.to(RankPage())),
            SearchButton(),
          ],
        ),
        backgroundColor: AppPalette.background,
        body: TabBarView(
          children: tabs.values.map((it) => DelayView(it)).toList(growable: false),
        ),
      ),
    );
  }
}
