import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/home/rank/rank_gift_detail_sheet.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tools.dart';

class RankGiftPage extends StatefulWidget {
  @override
  _RankGiftPageState createState() => _RankGiftPageState();
}

class _RankGiftPageState extends State<RankGiftPage> {
  final tabDateType = {'1': '日榜', '2': '总榜'};

  @override
  void initState() {
    super.initState();
  }

  Future getData(e) {
    return Api.Rank.getRankGiftList(e);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(IMG.$('礼物榜'), scale: 3, width: double.infinity, fit: BoxFit.fitWidth),
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 155),
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
                color: Colors.white),
            child: DefaultTabController(
                length: tabDateType.length,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      xAppBar$TabBar(
                        [...tabDateType.values.map((e) => Text(e)).toList(growable: false)],
                        alignment:  Alignment.bottomLeft,
                      ),
                      Spacing.exp,
                      Text(
                        '按照该礼物的获得数量排列',
                        style: TextStyle(color: AppPalette.hint, fontSize: 12),
                      ),
                      Spacing.w16,
                    ],
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    ...tabDateType.keys.map((e) {
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
                                itemBuilder: (context, index) {
                                  return xItem(data[index], index, e);
                                }),
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

  xItem(dynamic data, int index, String type) {
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

    return xFlatButton(
      55,
      Colors.white,
      radius: 0,
      margin: EdgeInsets.only(bottom: 30),
      onTap: () {
        Get.showBottomSheet(
          RankGiftDetailSheet(
            giftData: data,
            index: index,
            type: type,
          ),
        );
      },
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
          RectAvatarView(
            size: 47,
            url: data['picUrl'],
            radius: 12.0,
          ),
          Spacing.w8,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(xMapStr(data, 'giftName'), style: TextStyle(color: AppPalette.dark, fontSize: 14)),
            ],
          ),
          Spacing.exp,
          Row(children: [
            // MoneyIcon(size: 20),
            Text('${xMapStr(data, 'giftNum', defaultStr: 0)}个',
                style: TextStyle(color: AppPalette.primary, fontSize: 14)),
          ]),
          Spacing.w8,
          Icon(Icons.keyboard_arrow_right, color: Theme.of(context).disabledColor),
        ],
      ),
    );
  }
}
