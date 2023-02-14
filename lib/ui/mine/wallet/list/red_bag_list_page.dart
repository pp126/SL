import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RedBagListPage extends StatefulWidget {
  RedBagListPage();

  @override
  _RedBagListPageState createState() => _RedBagListPageState();
}

class _RedBagListPageState extends NetPageList<Map, RedBagListPage> {
  @override
  Future fetchPage(PageNum page) {
    return Api.Packet.queryPacketInfo(page);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return xItem(item);
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
        physics: NeverScrollableScrollPhysics(), shrinkWrap: true);
  }

  Widget xItem(Map item) {
    String goldNum = xMapStr(item, 'packetNum', defaultStr: '0').toString();
    String time = TimeUtils.getDateStrByMs(
        xMapStr(item, 'createTime', defaultStr: 0),
        format: DateFormat.NORMAL);
    TextStyle defaultStyle = TextStyle(fontSize: 14, color: AppPalette.dark);
    TextStyle style = TextStyle(fontSize: 14, color: AppPalette.hint);

    Widget widget = SizedBox();
    Widget widget1 = SizedBox();
    final type = xMapStr(item, 'type');
    if (type == 0) {
      widget1 = Text('(已退回)');
    }
    if (type == 1 || type == 0) {
      //送出
      widget = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '赠送红包给 '),
            TextSpan(
                text: '${xMapStr(item, 'targetNick', defaultStr: '')}',
                style: style),
          ],
        ),
        style: defaultStyle,
        maxLines: 2,
      );
    } else if (type == 2) {
      //收到
      widget = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '收到 '),
            TextSpan(
                text: '${xMapStr(item, 'nick', defaultStr: '')} 的红包',
                style: style),
          ],
        ),
        style: defaultStyle,
        maxLines: 2,
      );
    }
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget,
                      Spacing.h4,
                      Text(
                        time,
                        style: TextStyle(fontSize: 10, color: AppPalette.hint),
                      ),
                    ],
                  ),
                ),
                Spacing.w4,
                Text(
                  '${type == 2 ? '+' : '-'} $goldNum',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: type == 2 ? AppPalette.pink : AppPalette.primary,
                      fontSize: 14),
                  maxLines: 2,
                ),
                Spacing.w4,
                Image.asset(
                  IMG.$('海星'),
                  width: 21,
                  height: 19,
                ),
                widget1
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
