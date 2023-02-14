import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletGoldListPage extends StatefulWidget {
  final int type;
  WalletGoldListPage(this.type);

  @override
  _WalletGoldListPageState createState() => _WalletGoldListPageState();
}

class _WalletGoldListPageState extends NetPageList<Map, WalletGoldListPage> {
  @override
  Future fetchPage(PageNum page) {
    return Api.User.billrecordGet(widget.type,page.index.toString());
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return xItem(item);
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(physics: NeverScrollableScrollPhysics(), shrinkWrap: true);
  }

  Widget xItem(Map item) {
    String goldNum = xMapStr(item, 'goldNum',defaultStr: 0).toString();
    Widget content = SizedBox();
    String time = TimeUtils.getDateStrByMs(xMapStr(item, 'recordTime'),format:DateFormat.NORMAL);
    Color color = AppPalette.primary;
    TextStyle defaultStyle = TextStyle(fontSize: 14, color: AppPalette.dark);
    TextStyle style = TextStyle(fontSize: 14, color: AppPalette.hint);
    String unit = '';
    switch(widget.type){
      case 1:
        {
          content = Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '赠送 '),
                TextSpan(text: '${xMapStr(item, 'giftName')}', style: style),
                TextSpan(text: ' 给 '),
                TextSpan(text: '${xMapStr(item, 'targetNick')}', style: style),
              ],
            ),
            style: defaultStyle,
            maxLines: 2,
          );
          color = AppPalette.pink;
          goldNum = '-$goldNum';
          unit = '海星';
        }
        break;
      case 2:
        {
          content = Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '收到 '),
                TextSpan(text: '${xMapStr(item, 'targetNick')}', style: style),
                TextSpan(text: ' 赠送的 '),
                TextSpan(text: '${xMapStr(item, 'giftName')}', style: style),
              ],
            ),
            style: defaultStyle,
            maxLines: 2,
          );
          color = AppPalette.primary;
          goldNum = '+${xMapStr(item, 'diamondNum',defaultStr: 0)}';
          unit = '珍珠';
        }
        break;
      case 4:
        {
          String showStr = xMapStr(item, 'showStr',defaultStr: 0).toString();
          content = Text.rich(
            TextSpan(
              children: [
                TextSpan(text: showStr??'充值海星'),
              ],
            ),
            style: defaultStyle,
            maxLines: 2,
          );
          color = AppPalette.primary;
          goldNum = '+$goldNum';
          unit = '海星';
        }
        break;
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
                      content,
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
                  goldNum,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: color, fontSize: 14),
                  maxLines: 2,
                ),
                Spacing.w4,
                Image.asset(IMG.$(unit),width: 21,height: 19,),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
