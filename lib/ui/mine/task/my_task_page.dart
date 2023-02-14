import 'package:app/common/theme.dart';
import 'package:app/event/pay_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/task/coral_detail_page.dart';
import 'package:app/ui/mine/task/do_task_page.dart';
import 'package:app/ui/mine/task/my_sign_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class MyTaskPage extends StatefulWidget {
  @override
  _MyTaskPageState createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CoinItem(),
          Container(
            margin: EdgeInsets.only(top: 0),
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "趣味玩法",
                  style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: fw$SemiBold),
                ),
                MySignItem(
                  showSign: false,
                ),
                SizedBox(height: 30),
                gotoTask(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  gotoTask() {
    return AspectRatio(
      aspectRatio: 343 / 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            IMG.$('任务背景'),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: '成长中心', style: TextStyle(color: Colors.white, fontSize: 16)),
                  TextSpan(
                      text: '\n做任务得积分，更多奖励等你来拿',
                      style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 12)),
                ])),
                Text(
                  '做任务',
                  style: TextStyle(color: AppPalette.pink),
                ).toBtn(26, Colors.white,
                    radius: 7,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                  onTap: () async {
                    Get.to(DoTaskPage());
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoinItem extends StatefulWidget {
  final bool showDetail;
  CoinItem({this.showDetail = true});
  @override
  CoinItemState createState() => new CoinItemState();
}

class CoinItemState extends State<CoinItem> {
  final _key = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
    Bus.on<CoinChangeEvent>((data) {
      doRefresh();
    });
  }
  Future<Map> getCoinData(){
    return Api.Task.coinInfo();
  }

  doRefresh(){
    _key.currentState.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<Map>(
        key: _key,
        futureBuilder: getCoinData, onData: (data) {
      return Container(
        color: AppPalette.background,
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 124,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${xMapStr(data, 'mcoinNum',defaultStr: 0)}',
                    style: TextStyle(color: AppPalette.primary, fontSize: 30,fontWeight: fw$SemiBold),
                  ),
                  Spacing.h4,
                  Text(
                    '我的珊瑚',
                    style: TextStyle(color: AppPalette.dark, fontSize: 14),
                  )
                ],
              ),
            ),
            if(widget.showDetail)Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 30,
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  color: Colors.white,
                ),
                Text(
                  '明细',
                  style: TextStyle(color: AppPalette.primary, fontSize: 14),
                ).toBtn(30, AppPalette.txtWhite, width: 72,onTap: (){
                  Get.to(CoralDetailPage());
                }),
              ],
            )
          ],
        ),
      );
    });
  }

  @override
  void didUpdateWidget(CoinItem oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}