
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/task/my_task_page.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:app/widgets/spacing.dart';
import 'package:app/widgets/tips_view.dart';
import 'package:app/widgets/view_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CoralDetailPage extends StatefulWidget {
  @override
  CoralDetailPageState createState() => new CoralDetailPageState();
}

class CoralDetailPageState extends State<CoralDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('珊瑚明细'),
      body: CoralListItem(),
    );
  }
}

class CoralListItem extends StatefulWidget {
  @override
  _CoralListItemState createState() => _CoralListItemState();
}

class _CoralListItemState extends NetPageList<Map, CoralListItem> {
  @override
  Future fetchPage(PageNum page) => Api.User.coralRecord(page.index.toString());

  @override
  Widget itemBuilder(BuildContext context, Map item, int index){
    return xItem(item);
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      noTipsImage: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfigListState(
      buildEmptyView: ([Tuple2<VoidCallback, bool> arg]) => TipsView(arg.item1, tipsType: TipsType.empty,noImage: true,message: '暂时没有相关明细哦！',),
      child: super.build(context),
    );
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => SingleChildScrollView(
    child: Column(
      children: [
        CoinItem(showDetail: false,),
        child
      ],
    ),
  );

  Widget xItem(Map item) {
    int type = xMapStr(item, 'type',defaultStr: 1);///1.签到(增加) 2.兑换道具(消耗) 3.成长任务(增加)4.活动(增加)5.抽奖(消耗) 6.支持(消耗)")
    String mcoinNum = xMapStr(item, 'mcoinNum',defaultStr: 0).toString();
    String time = TimeUtils.getDateStrByMs(xMapStr(item, 'createTime'),format:DateFormat.NORMAL);
    String desc = xMapStr(item, 'desc',defaultStr: 0).toString();
    Color color = AppPalette.primary;
    TextStyle defaultStyle = TextStyle(fontSize: 14, color: AppPalette.dark);
    TextStyle style = TextStyle(fontSize: 10, color: AppPalette.hint);
    String unit = '珊瑚';
    switch(type){
      case 1:
      case 3:
      case 4:
        {
          color = AppPalette.primary;
          mcoinNum = '+$mcoinNum';
        }
        break;
      case 2:
      case 5:
      case 6:
        {
          color = AppPalette.pink;
          mcoinNum = '-$mcoinNum';
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
                      Text(
                        desc,
                        style: defaultStyle,
                        maxLines: 2,
                      ),
                      Spacing.h4,
                      Text(
                        time,
                        style: style,
                      ),
                    ],
                  ),
                ),
                Spacing.w4,
                Text(
                  mcoinNum,
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
