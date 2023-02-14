import 'package:app/common/theme.dart';
import 'package:app/ui/auction/add_auction_page.dart';
import 'package:app/ui/auction/auction_home_view.dart';
import 'package:app/ui/auction/auction_self_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AuctionPage extends StatefulWidget {
  @override
  _AuctionPageState createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  final tabs = {
    '\u3000拍卖大厅': AuctionHomeView(),
    '我的拍卖品': AuctionSelfView(),
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppPalette.background,
        appBar: xAppBar(
          xAppBar$TabBar(tabs.keys.map((it) => Tab(text: it)).toList(growable: false)),
          bgColor: Colors.white,
        ),
        body: TabBarView(children: tabs.values.toList(growable: false)),
      ),
    );
  }
}
