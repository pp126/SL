import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/send/send_user_list.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

///赠送商品
class SendUserPage extends StatefulWidget {
  final productData;

  ///商品
  final ProductType type;

  SendUserPage({this.productData, this.type});

  @override
  SendUserPageState createState() => new SendUserPageState();
}

class SendUserPageState extends State<SendUserPage> {
  final tabs = [
    {'title': '好友', 'type': UserType.friend},
    {'title': '关注', 'type': UserType.follow},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: xAppBar('赠送'),
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(delegate: TabBarPersistentHeaderDelegate(_buildTabBar(), 44), pinned: true),
            ];
          },
          body: TabBarView(
            children: tabs.map((e) {
              return SendUserListView(
                type: e['type'],
                productType: widget.type,
                productData: widget.productData,
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }

  _buildTabBar() {
    final List<Widget> views = tabs.map((e) {
      return Tab(text: e['title']);
    }).toList(growable: false);
    return Material(
      color: Colors.white,
      child: xAppBar$TabBar(views, alignment:Alignment.centerLeft),
    );
  }
}
