import 'package:app/common/bus_key.dart';
import 'package:app/net/api.dart';
import 'package:app/tools/bus.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';

import '../../../../tools.dart';
import '../../avatar_view.dart';

class WaterList extends StatefulWidget {
  final int roomUid;
  final RxMap data;
  final String label;

  WaterList(this.data, this.roomUid, this.label);

  @override
  _WaterListState createState() => _WaterListState();
}

class _WaterListState extends NetPageList<dynamic, WaterList> {
  int sumFlow = 0;

  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_WATER_LIST_REFRESH, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_WATER_LIST_REFRESH);
  }

  @override
  List<dynamic> transform(data) {
    sumFlow = data['sumFlow'];

    return super.transform(data['list']);
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Room.getRoomFlowDetail(
        roomUid: widget.roomUid,
        beginDate: widget.data['start'],
        endDate: widget.data['end'],
        pageNum: page.index,
        pageSize: page.size);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Row(
            children: [
              Text(
                '${widget.label}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Spacing(),
              MoneyIcon(type: '珍珠'),
              Spacing.w4,
              Text('${sumFlow ?? 0}',
                  style: TextStyle(color: Color(0xff7C66FF), fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(child: super.build(context))
      ],
    );
  }

  @override
  Widget itemBuilder(BuildContext context, dynamic item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.to(UserPage(uid: xMapStr(item, 'sendUid', defaultStr: null))),
            child: AvatarView(
              url: xMapStr(item, 'sendAvatar'),
              size: 50,
            ),
          ),
          Spacing.w10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  xMapStr(item, 'sendNick'),
                  style: TextStyle(fontSize: 12),
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Spacing.h8,
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '送给', style: TextStyle(color: Color(0xffCBC8DC), fontSize: 12)),
                    TextSpan(
                      text: xMapStr(item, 'receiveNick'),
                      style: TextStyle(fontSize: 12),
                    ),
                  ]),
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: xMapStr(item, 'giftName'),
                    style: TextStyle(color: Color(0xff7C66FF), fontSize: 12),
                  ),
                  TextSpan(text: ' 礼物 ', style: TextStyle(fontSize: 12)),
                  TextSpan(
                    text: '*${xMapStr(item, 'giftNum')}',
                    style: TextStyle(color: Color(0xff7C66FF), fontSize: 12),
                  ),
                ]),
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Spacing.h8,
              Text(
                '${xMapStr(item, 'totalGoldNum')}海星',
                style: TextStyle(color: Color(0xff7C66FF), fontSize: 12),
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          Spacing.w10,
          NetImage(xMapStr(item, 'giftUrl'), width: 50, height: 50)
        ],
      ),
    );
  }
}
