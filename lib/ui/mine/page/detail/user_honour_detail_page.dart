import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/widgets/tab_bar_persistent_header_delegate.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/detail/user_honour_list_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/delay_view.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class UserHonourDetailPage extends StatefulWidget {
  final int uid;
  final Map userInfo;
  final HonourType type;
  final String title;

  UserHonourDetailPage({
    this.uid,
    this.userInfo,
    this.type = HonourType.gift,
    this.title,
  });

  @override
  _UserHonourDetailPageState createState() => _UserHonourDetailPageState();
}

class _UserHonourDetailPageState extends State<UserHonourDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        widget.title ?? '详情',
      ),
      body: _UserHonourItem(
        uid: widget.uid,
        userInfo: widget.userInfo,
        type: widget.type,
      ),
    );
  }
}

class _UserHonourItem extends StatefulWidget {
  final int uid;
  final Map userInfo;
  final HonourType type;

  _UserHonourItem({
    this.uid,
    this.userInfo,
    this.type = HonourType.gift,
  });

  @override
  _UserHonourItemState createState() => _UserHonourItemState();
}

class _UserHonourItemState extends State<_UserHonourItem> {
  final data = {
    HonourType.gift: {
      '全部': 0,
      '已点亮': 1,
      '未点亮': 2,
    },
    HonourType.car: {
      '全部': 0,
      '已获得': 1,
      '未获得': 2,
    },
    HonourType.head: {
      '全部': 0,
      '已获得': 1,
      '未获得': 2,
    },
  };

  @override
  Widget build(BuildContext context) {
    final tabs = data[widget.type];
    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          final tabBar = Material(
            color: Colors.white,
            child: xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              alignment: Alignment.centerLeft,
            ),
          );

          return [
            for (final it in [
              UserHonourView(
                uid: widget.uid,
                userInfo: widget.userInfo,
                type: widget.type,
              )
            ])
              SliverToBoxAdapter(child: it),
            SliverPersistentHeader(delegate: TabBarPersistentHeaderDelegate(tabBar, 44), pinned: true),
          ];
        },
        body: Material(
          color: Colors.white,
          child: TabBarView(
            children: tabs.values
                .map((it) => DelayView(UserHonourListPage(
                      uid: widget.uid,
                      type: widget.type,
                      dataType: it,
                    )))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class UserHonourView extends StatefulWidget {
  final int uid;
  final Map userInfo;
  final HonourType type;

  UserHonourView({this.uid, this.userInfo, this.type});

  @override
  _UserHonourViewState createState() => _UserHonourViewState();
}

class _UserHonourViewState extends State<UserHonourView> {
  Future<Map> getData() {
    switch (widget.type) {
      case HonourType.gift:
        return Api.User.userGiftList(
          userId: widget.uid.toString(),
          type: 1,
        );
        break;
      case HonourType.head:
        return Api.User.userHeadList(
          userId: widget.uid.toString(),
          type: 1,
        );
        break;
      case HonourType.car:
        return Api.User.userCarList(
          userId: widget.uid.toString(),
          type: 1,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserHonourItem();
  }

  _buildUserHonourItem() {
    final item = {
      HonourType.gift: [
        '点亮礼物：',
        '礼物总数：',
      ],
      HonourType.car: [
        'TA的座驾：',
        '座驾总数：',
      ],
      HonourType.head: [
        'TA的头饰：',
        '头饰总数：',
      ],
    }[widget.type];

    return XFutureBuilder<Map>(
        futureBuilder: getData,
        onData: (data) {
          TextStyle style = TextStyle(fontSize: 14, color: AppPalette.dark, fontWeight: fw$SemiBold);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AvatarView(
                size: 50,
                url: xMapStr(widget.userInfo, 'avatar'),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: item[0]),
                    TextSpan(
                      text: '${xMapStr(data, 'obtainedCount', defaultStr: 0)}',
                      style: style.copyWith(color: AppPalette.primary),
                    ),
                  ],
                ),
                style: style,
              ),
              Spacing.w4,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: item[1]),
                    TextSpan(
                      text: '${xMapStr(data, 'count', defaultStr: 0)}',
                      style: style.copyWith(color: AppPalette.primary),
                    ),
                  ],
                ),
                style: style,
              ),
            ],
          ).toTagView(
            74,
            AppPalette.background,
            margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
            padding: EdgeInsets.fromLTRB(10, 0, 30, 0),
          );
        });
  }

  Widget goldView(
    String title,
    String gold,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$gold',
            style: TextStyle(color: AppPalette.primary, fontSize: 30, fontWeight: fw$SemiBold),
          ),
          Text(
            title,
            style: TextStyle(color: AppPalette.dark, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
