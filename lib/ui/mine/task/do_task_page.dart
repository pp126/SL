import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/event/pay_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/mine/account/account_page.dart';
import 'package:app/ui/mine/account/des_page.dart';
import 'package:app/ui/mine/certify/certify_page.dart';
import 'package:app/ui/mine/safe/bind_phone.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/ui/moment/post/post_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

///成长中心
class DoTaskPage extends StatefulWidget {
  DoTaskPage({Key key}) : super(key: key);

  @override
  _DoTaskPageState createState() => _DoTaskPageState();
}

class _DoTaskPageState extends State<DoTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '成长中心',
      ),
      backgroundColor: AppPalette.background,
      body: _TaskPage(),
    );
  }
}
class _TaskPage extends StatefulWidget {
  @override
  __TaskPageState createState() => __TaskPageState();
}

class __TaskPageState extends State<_TaskPage> {
  final _key = GlobalKey<XFutureBuilderState>();

  Future<List> getData(){
    return Api.Task.taskList(type: 1);
  }
  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<List>(
        key: _key,
        futureBuilder: getData,
        emptyType: TipsType.empty,
        onData: (data) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((e) => item(e)).toList(),
            ),
          );
        });
  }
  Widget item(var data) {
    var missionName = xMapStr(data, 'missionName').toString();
    var missionId = xMapStr(data, 'missionId').toString();
    var mcoinAmount = xMapStr(data, 'mcoinAmount',defaultStr: 0).toString();
    var missionStatus = xMapStr(data, 'missionStatus',defaultStr: 1);
    final status = {
      1 : ['做任务',AppPalette.txtWhite,AppPalette.primary,(){
        onItemClick(missionName);
      }],
      2 : ['领取奖励',AppPalette.primary,Colors.white,(){
        onGainTap(missionId);
      }],
      3 : ['已领取',AppPalette.txtWhite,AppPalette.tips,null],
    }[missionStatus];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    missionName,
                    style: TextStyle(color: AppPalette.dark, fontSize: 12,fontWeight: fw$SemiBold),
                ),
                Spacing.h6,
                Text.rich(TextSpan(children: [
                  TextSpan(text: '完成任务可获得：', style: TextStyle(color: AppPalette.tips, fontSize: 12)),
                  TextSpan(text: "$mcoinAmount珊瑚", style: TextStyle(color: AppPalette.primary, fontSize: 12)),
                ])),
              ],
            ),
          ),
          Spacing.w4,
          Text(
            status[0],
            style: TextStyle(color: status[2], fontSize: 10),
          ).toBtn(
            24,
            status[1],
            width: 60,
            onTap: status[3]
          ),
        ],
      ),
    );
  }

  Future<void> onItemClick(String item) async {
    switch (item) {
      case '设置头像':
        await Get.to(AccountPage());
        break;
      case '设置个性签名':
        await Get.to(DesPage());
        break;
      case '实名认证':
        await Get.to(CertifyPage());
        break;
      case '绑定手机':
        await Get.to(BindPhonePage());
        break;
    }
    doRefresh();
  }

  doRefresh(){
    _key.currentState.doRefresh();
  }
  ///领取奖励
  onGainTap(String missionId){
    simpleSub(Api.Task.gainCoin(
        missionId:missionId
    ), callback: () {
      doRefresh();
      Bus.fire(CoinChangeEvent());
    },msg: '签到成功');
  }

}
