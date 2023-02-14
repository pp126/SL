import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordBottomSheet extends StatelessWidget {
  final int drawType;

  RecordBottomSheet(this.drawType);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 15),
            child: Text('收集记录', style: TextStyle(fontSize: 16, color: AppPalette.txtWhite, fontWeight: fw$SemiBold)),
          ),
          Expanded(child: RecordBottomView(drawType))
        ],
      ),
    );
  }
}

class RecordBottomView extends StatefulWidget {
  final int drawType;

  RecordBottomView(this.drawType);

  @override
  _RecordBottomViewState createState() => _RecordBottomViewState();
}

class _RecordBottomViewState extends NetPageList<Map, RecordBottomView> {
  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => xItem(item);

  @override
  Future fetchPage(PageNum page) => Api.User.giftPurseRecord(widget.drawType, page.index, page.size);

  xItem(Map item) {
    String date = TimeUtils.getDateStrByDateTime(DateTime.fromMillisecondsSinceEpoch(item['createTime']),
        format: DateFormat.NORMAL);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${xMapStr(item, 'giftName')} x ${xMapStr(item, 'giftNum')}（${xMapStr(item, 'goldCost')}海星）',
                  style: TextStyle(color: AppPalette.txtWhite, fontSize: 14)),
              SizedBox(height: 8),
              Text(date, style: TextStyle(color: Color(0xff7C66FF), fontSize: 12)),
            ],
          )),
          AvatarView(
            size: 40,
            url: item['avatar'],
          ),
        ],
      ).toWarp(color: Color(0xff191535), radius: 12, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
    );
  }
}
