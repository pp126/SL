import 'package:app/common/theme.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/wallet/list/wallet_gold_list_page.dart';
import 'package:app/ui/mine/wallet/wallet_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/delay_view.dart';
import 'package:flutter/material.dart';

import 'list/red_bag_list_page.dart';

class WalletListPage extends StatefulWidget {
  @override
  _WalletListPageState createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '钱包记录',
      ),
      backgroundColor: AppPalette.background,
      body: _WalletRecordItem(),
    );
  }
}

class _WalletRecordItem extends StatefulWidget {
  @override
  __WalletRecordItemState createState() => __WalletRecordItemState();
}

class __WalletRecordItemState extends State<_WalletRecordItem> {
  final tabs = {
    '收礼记录': WalletGoldListPage(2),
    '送礼记录': WalletGoldListPage(1),
    '充值记录': WalletGoldListPage(4),
    '红包记录': RedBagListPage(),
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          final tabBar = Material(
            color: Colors.white,
            child: xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              isScrollable: false,
            ),
          );
          return [
            SliverToBoxAdapter(child: WalletItem()),
            SliverPersistentHeader(delegate: TabBarPersistentHeaderDelegate(tabBar, 44), pinned: true),
          ];
        },
        body: Material(
          color: Colors.white,
          child: TabBarView(
            children: tabs.values.map((it) => DelayView(it)).toList(growable: false),
          ),
        ),
      ),
    );
  }
}
