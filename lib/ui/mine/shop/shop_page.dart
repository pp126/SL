import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/activity/activity_detail_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/shop/package_page.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/ui/mine/shop/shop_item.dart';
import 'package:app/ui/room/gift_effect_overlay.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/overlay_mixin.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

///商城
class ShopPage extends StatefulWidget {
  final int uid;

  ShopPage({this.uid});

  @override
  ShopPageState createState() => new ShopPageState();
}

class ShopPageState extends State<ShopPage> with OverlayMixin, BusStateMixin {
  var api;
  bool isShowBlackTitle = false;
  var activityData;
  final tabs = {'座驾': ProductType.car, '头饰': ProductType.head};

  Future<List> getData() {
    return Api.Home.getIndexTopBanner();
  }

  //判断滚动改变透明度
  void _onScroll(offset) {
    if (offset > 40) {
      setState(() {
        isShowBlackTitle = true;
      });
    } else {
      setState(() {
        isShowBlackTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: xAppBar(
        '商城',
        action: '背包'.toTxtActionBtn(onPressed: () => Get.to(MyPackagePage())),
      ),
      body: NotificationListener(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0) {
              //滚动并且是列表滚动的时候
              _onScroll(scrollNotification.metrics.pixels);
            }
            return true;
          },
          child: Stack(
            children: <Widget>[
              DefaultTabController(
                length: tabs.length,
                child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        delegate: _TabBarPersistentHeaderDelegate(_buildTabBar(), 80, 200),
                        pinned: true,
                      ),
                    ];
                  },
                  body: Container(
                    color: Colors.white,
                    child: TabBarView(
                      children: tabs.values.map((it) {
                        return ShopItem(
                          type: it,
                        );
                      }).toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  _buildTopView() {
    return XFutureBuilder<List>(
      futureBuilder: getData,
      onData: (data) {
        activityData = xListStr(data, 0, defaultStr: null);
        return activityData != null
            ? GestureDetector(
                onTap: goToActivity,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  margin: EdgeInsets.only(bottom: 1),
                  child: NetImage(activityData['bannerPic'], fit: BoxFit.cover),
                ),
              )
            : Container(
                width: double.infinity,
                height: 200,
                color: AppPalette.background,
              );
      },
    );
  }

  _buildTabBar() {
    double height = 80;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _buildTopView(),
        Container(
          height: height / 2.0,
          margin: EdgeInsets.only(top: height / 2.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )),
        ),
        Container(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: xAppBar$TabBar(
                  tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
                  alignment: Alignment.bottomLeft,
                ),
              ),
              Spacing.w4,
              Container(
                padding: EdgeInsets.all(6),
                decoration: ShapeDecoration(color: Colors.white, shape: StadiumBorder()),
                child: SelfView(size: 48),
              ),
              Spacing.w16,
            ],
          ),
        ),
      ],
    );
  }

  goToActivity() {
    if (activityData != null) {
      ActivityDetailPage.to(activityData);
    }
  }

  @override
  List<Widget> get overlay => [GiftEffectOverlay()];
}

class _TabBarPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final double minHeight;
  final double maxHeight;

  _TabBarPersistentHeaderDelegate(this.tabBar, this.minHeight, this.maxHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => tabBar;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
