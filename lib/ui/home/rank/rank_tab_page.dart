import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/level_view.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tools.dart';

class RankTabPage extends StatefulWidget {
  final String type;

  RankTabPage(this.type);

  @override
  _RankTabPageState createState() => _RankTabPageState();
}

class _RankTabPageState extends State<RankTabPage> {
  final tabTypes = {'2': '财富榜', '1': '魅力榜', '3': '礼物榜'};
  final tabDatetype = {'1': '日榜', '2': '周榜', '3': '月榜'};

  @override
  void initState() {
    super.initState();
  }

  Future getData(e) {
    return Api.Rank.getRankingList(widget.type, e);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          IMG.$('${tabTypes[widget.type]}'),
          scale: 3,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 155),
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
                color: Colors.white),
            child: DefaultTabController(
                length: tabDatetype.length,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  xAppBar$TabBar(
                    [...tabDatetype.values.map((e) => Text(e)).toList(growable: false)],
                    alignment: Alignment.bottomLeft,
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    ...tabDatetype.keys.map((e) {
                      final _key = GlobalKey<XFutureBuilderState>();
                      return XFutureBuilder<dynamic>(
                        key: _key,
                        futureBuilder: () {
                          return getData(e);
                        },
                        onData: (data) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              _key.currentState.doRefresh();
                              await Future.delayed(Duration(seconds: 1));
                            },
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) => xItem(data[index], index),
                            ),
                          );
                        },
                        tipsSize: 150,
                      );
                    }).toList(growable: false)
                  ]))
                ]))),
      ],
    );
  }

  xItem(dynamic data, int index) {
    SvgPicture crown;
    switch (index) {
      case 0:
      case 1:
      case 2:
        crown = SvgPicture.asset(
          SVG.$('home/rank/crown_${index + 1}'),
          width: 26,
          height: 26,
        );
        break;
    }
    bool isMan = xMapStr(data, 'gender') == 1;
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 26),
            child: Center(
              child: crown != null
                  ? crown
                  : Text(index.toString(), style: TextStyle(color: AppPalette.tips, fontSize: 16)),
            ),
          ),
          Spacing.w8,
          InkWell(
            onTap: () => Get.to(UserPage(
              uid: xMapStr(data, 'uid', defaultStr: null),
            )),
            child: AvatarView(
              size: 47,
              url: data['avatar'],
            ),
          ),
          Spacing.w8,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  xMapStr(data, 'nick'),
                  style: TextStyle(color: AppPalette.dark, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SvgPicture.asset(SVG.$('mine/性别_${isMan ? 1 : 2}')),
                  Spacing.w4,
                  WealthIcon(data: data),
                ]),
              ],
            ),
          ),
          Spacing.w10,
          Row(children: [
            MoneyIcon(size: 20),
            Text('${xMapStr(data, 'totalNum', defaultStr: 0)}',
                style: TextStyle(color: AppPalette.primary, fontSize: 14)),
          ]),
        ],
      ),
    );
  }
}
