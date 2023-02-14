import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/shop/my_package_item.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

///装扮
class MyWearPage extends StatefulWidget {
  final int uid;

  MyWearPage({this.uid});

  @override
  MyWearPageState createState() => new MyWearPageState();
}

class MyWearPageState extends State<MyWearPage> {
  var api;
  bool isShowBlackTitle = false;

  final tabs = {'座驾': ProductType.car, '头饰': ProductType.head};

  Future<List> getData() {
    return Api.Home.getIndexTopBanner();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildTopView(),
            ),
            SliverPersistentHeader(delegate: TabBarPersistentHeaderDelegate(_buildTabBar(), 40), pinned: true),
          ];
        },
        body: TabBarView(
          children: tabs.values.map((it) {
            return MyPackageItem(
              type: it,
            );
          }).toList(growable: false),
        ),
      ),
    );
  }

  _buildTopView() {
    return GetX<OAuthCtrl>(builder: (it) {
      var userInfo = it.info.value;
      String carUrl = xMapStr(userInfo, 'carUrl');
      String carName = xMapStr(userInfo, 'carName');
      String headwearUrl = xMapStr(userInfo, 'headwearUrl');
      String headwearName = xMapStr(userInfo, 'headwearName');
      print(userInfo);
      print('carUrl=$carUrl');
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [
                Color(0xffA183FF),
                Color(0xff7C66FF),
              ]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '当前装扮',
                    style: TextStyle(fontSize: 16, color: AppPalette.dark, fontWeight: fw$SemiBold),
                  ),
                  Spacing.w16,
                  Column(
                    children: [
                      RectAvatarView(
                        size: 48,
                        url: carUrl,
                      ),
                      Spacing.h4,
                      Text(
                        '入场特效',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.dark,
                        ),
                      ),
                    ],
                  ),
                  Spacing.w16,
                  Column(
                    children: [
                      RectAvatarView(
                        size: 48,
                        url: headwearUrl,
                      ),
                      Spacing.h4,
                      Text(
                        '头像框',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.dark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  _buildTabBar() {
    return Material(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              alignment:  Alignment.bottomLeft,
            ),
          ),
          Spacing.w4,
          Container(
            padding: EdgeInsets.all(2),
            decoration: ShapeDecoration(color: Colors.white, shape: StadiumBorder()),
            child: SelfView(size: 56),
          ),
          Spacing.w16,
        ],
      ),
    );
  }
}
