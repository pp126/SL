import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/common/banner_view.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/moment/moment_sub_item.dart';
import 'package:app/ui/moment/topic/topic_page.dart';
import 'package:app/ui/moment/topic/topic_title_item.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_swiper_pagination.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../../common/theme.dart';
import '../../widgets.dart';

class MomentIndexView extends StatefulWidget {
  @override
  _MomentIndexViewState createState() => _MomentIndexViewState();
}

class _MomentIndexViewState extends State<MomentIndexView> {
  final tabs = {
    '热门': MomentSubItem(type: 1,),
    '最新': MomentSubItem(type: 2,),
    '关注': MomentSubItem(type: 3,),
    '心愿': MomentSubItem(type: 4,),
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          final tabBar = Material(
            child: xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              alignment:Alignment.bottomLeft,
            ),
          );

          return [
            for (final it in [BannerView(), _RecommendRoomView()]) SliverToBoxAdapter(child: it),
            SliverPersistentHeader(delegate: TabBarPersistentHeaderDelegate(tabBar, 44), pinned: true),
          ];
        },
        body: TabBarView(
          children: tabs.values.map((it) => DelayView(it)).toList(growable: false),
        ),
      ),
    );
  }
}

class _RecommendRoomView extends StatefulWidget {
  @override
  __RecommendRoomViewState createState() => __RecommendRoomViewState();
}

class __RecommendRoomViewState extends State<_RecommendRoomView> {
  Future<List> getData(){
    return Api.Moment.topicList(PageNum());
  }

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<List>(
        futureBuilder: getData,
        tipsSize: 100,
        onData: (data) {
      return Container(
        child: Column(
          children: <Widget>[
            _GroupTitleView(icon: 'moment/hot', title: '热门话题'),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: data.map((v){
                  return TopicTitleItem(data: v, height: 32);
                }).toList(),
              ),
            )
          ],
        ),
      );
    });
  }
}

class _GroupTitleView extends StatelessWidget {
  final String icon;
  final String title;

  _GroupTitleView({this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SvgPicture.asset(SVG.$(icon)),
          Spacing.w2,
          Text(
            title,
            style: TextStyle(fontSize: 16, color: AppPalette.dark,fontWeight: fw$SemiBold),
          ),
          Spacing.exp,
          AppTextButton(
            width: 60,
            height: 40,
            alignment: Alignment.centerRight,
            title: Text(
              '更多',
              style: TextStyle(fontSize: 14, color: AppPalette.tips),
            ),
            onPress: (){
              Get.to(TopicPage());
            },
          ),
        ],
      ),
    );
  }
}

