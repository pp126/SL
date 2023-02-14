import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/common/tag_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../tools.dart';

class RankRoomPage extends StatefulWidget {
  @override
  _RankRoomPageState createState() => _RankRoomPageState();
}

class _RankRoomPageState extends State<RankRoomPage> {
  final tabDateType = {
    '1': '日榜',
  };

  @override
  void initState() {
    super.initState();
  }

  Future getData() {
    return Api.Room.listAllRoomFlowDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(IMG.$('房间榜'), scale: 3, width: double.infinity, fit: BoxFit.fitWidth),
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
                        alignment:Alignment.bottomLeft,
                      ),
                      Spacing.exp,
                      Text(
                        '按照该房间的流水排列',
                        style: TextStyle(color: AppPalette.hint, fontSize: 12),
                      ),
                      Spacing.w16,
                    ],
                  ),
                  Expanded(
                      child: TabBarView(children: [
                    ...tabDateType.keys.map(
                      (e) {
                        final _key = GlobalKey<XFutureBuilderState>();
                        return XFutureBuilder<dynamic>(
                          key: _key,
                          futureBuilder: () {
                            return getData();
                          },
                          onData: (data) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                _key.currentState.doRefresh();
                                await Future.delayed(Duration(seconds: 1));
                              },
                              child: ListView.builder(
                                  itemCount: data.length,
                                  padding: EdgeInsets.only(top: 5),
                                  itemBuilder: (context, index) {
                                    return xItem(data[index], index, e);
                                  }),
                            );
                          },
                          tipsSize: 150,
                        );
                      },
                    ).toList(growable: false)
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
      onTap: () => RoomPage.to(data['uid']),
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
          AvatarView(size: 62, url: data['avatar']),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  TagIcon(tag: data['tagPict']),
                  SizedBox(width: 5),
                  Text(data['title'] ?? '',
                      style: TextStyle(color: AppPalette.dark, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)
                ]),
                SizedBox(height: 11),
                Row(
                  children: [
                    Text(
                      'ID:${data['roomId']}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ).toTagView(16, Colors.black.withAlpha(20), radius: 2),
                  ],
                )
              ],
            ),
          ),
          Spacing.h4,
          MoneyIcon(),
          Spacing.h6,
          Text('${xMapStr(data, 'totalGold', defaultStr: '0')}',
              style: TextStyle(color: AppPalette.primary, fontSize: 14)),
        ],
      ),
    );
  }
}
