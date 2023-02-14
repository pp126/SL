import 'package:app/net/api.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/common/banner_view.dart';
import 'package:app/ui/home/common/public_chat_view.dart';
import 'package:app/ui/home/index/home_index_hot_view.dart';
import 'package:app/ui/home/index/home_index_recommend_view.dart';
import 'package:app/ui/home/widgets/home_card.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import 'home_index_room_view.dart';

class HomeIndexView extends StatefulWidget {
  @override
  _HomeIndexViewState createState() => _HomeIndexViewState();
}

class _HomeIndexViewState extends State<HomeIndexView> {
  final List _tabs =
      ['推荐', '热门'].map<dynamic>((it) => {'name': it}).toList(growable: false);

  List recommendData = [];

  @override
  void initState() {
    loadRecommendData();
    super.initState();
  }

  void loadRecommendData() async {
    recommendData = await Api.Home.recommendRoom(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_HomeIndexCtrl>(
      init: _HomeIndexCtrl(),
      builder: (it) {
        final tabs = it.value != null ? _tabs + it.value : _tabs;

        // return DefaultTabController(
        //   length: tabs.length,
        //   child: Column(
        //     children: [
        //       xAppBar$TabBar(
        //         tabs.map((it) => Tab(text: it['name'])).toList(growable: false),
        //         alignment: Alignment.bottomLeft,
        //       ),
        //       Expanded(
        //         child: TabBarView(
        //           children: tabs
        //               .map((it) => DelayView(itemBuilder(it)))
        //               .toList(growable: false),
        //         ),
        //       ),
        //     ],
        //   ),
        // );
        return itemBuilder(null);
      },
    );
  }

  Widget itemBuilder(data) {
    Widget child;

    // switch (data['name']) {
    //   case '推荐':
    //     child = HomeIndexRecommendView();
    //     break;
    //   case '热门':
    //     child = HomeIndexHotView();
    //     break;
    //   default:
    //     child = HomeIndexRoomView(data);
    // }

    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverToBoxAdapter(child: BannerView()),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(child: PublicChatView()),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text('推荐房间'),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: recommendData.map((item) {
                      return Container(
                        width: (MediaQuery.of(context).size.width - 51) / 3,
                        height:
                            (MediaQuery.of(context).size.width - 51) / 3 + 30,
                        child: RoomCard(item),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: EdgeInsets.only(top: 15),

              child: Text('热门房间'),
            ),
          ),
        ),
      ],
      body: Container(
        color: Colors.white,
        child: HomeIndexHotView(),
      ),
    );
  }
}

class _HomeIndexCtrl extends AsyncCtrl<List> {
  @override
  Future get api => Api.Home.homeTag();

  @override
  String get persistent => PrefKey.HomeIndexTab;
}
