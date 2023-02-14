import 'package:app/common/theme.dart';
import 'package:app/event/pay_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

class MySignItem extends StatefulWidget {
  final bool showSign;

  MySignItem({
    this.showSign = false,
  });

  ///显示签到
  static Future show() async {
    try {
      if (await Api.Task.checkSign() != true) {
        await showDialog(
          context: Get.context,
          barrierDismissible: true,
          builder: (_) => MySignItem(showSign: true),
        );
      }
    } catch (e) {
      errLog(e);
    }
  }

  @override
  _MySignItemState createState() => _MySignItemState();
}

class _MySignItemState extends State<MySignItem> {
  final _weekKey = GlobalKey<XFutureBuilderState>();
  List signData;

  @override
  void initState() {
    super.initState();
  }

  Future<List> getWeekData() {
    return Api.Task.taskList(type: 3);
  }

  @override
  Widget build(BuildContext context) {
    return XFutureBuilder<List>(
        key: _weekKey,
        tipsSize: 100,
        futureBuilder: getWeekData,
        onData: (data) {
          signData = data;
          return widget.showSign ? showSignItem() : signIn(false);
        });
  }

  signIn(bool showSign) {
    var child = Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.only(top: 55, bottom: 10),
          decoration: BoxDecoration(
            color: AppPalette.divider,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: signData.map((e) => xItem(e)).toList(),
                ),
              ),
              showSign
                  ? Text(
                      '点击签到',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: fw$SemiBold),
                    ).toBtn(
                      40,
                      AppPalette.primary,
                      margin: const EdgeInsets.fromLTRB(34, 25, 34, 15),
                      onTap: onSignTap,
                    )
                  : SizedBox(),
            ],
          ),
        ),
        Image.asset(IMG.$('签到背景'), scale: 3),
        Positioned(
          left: 20,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 38, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('每日签到', style: TextStyle(color: Color(0xff7D3C00), fontSize: 16, fontWeight: FontWeight.w600)),
                Text('周末签到有丰富奖励哦', style: TextStyle(color: Color(0xff7D3C00), fontSize: 12)),
              ],
            ),
          ),
        ),
//          Positioned(
//            bottom: 10,
//            child: Text.rich(TextSpan(children: [
//              TextSpan(text: '周末签到有丰富奖励哦', style: TextStyle(color: AppPalette.hint, fontSize: 10)),
//            ])),
//          ),
      ],
    );
    return showSign
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(style: TextStyle(), child: child),
            ),
          )
        : GestureDetector(
            onTap: showSignItem,
            child: child,
          );
  }

  Widget xItem(var data) {
    var missionName = xMapStr(data, 'missionName').toString();
    var mcoinAmount = xMapStr(data, 'mcoinAmount').toString();
    var freebiesUrl = xMapStr(data, 'freebiesUrl').toString();
    var freebiesName = xMapStr(data, 'freebiesName').toString();
    var giftUrl = xMapStr(data, 'giftUrl').toString();
    var giftName = xMapStr(data, 'giftName').toString();
    bool canSign = xMapStr(data, 'missionStatus', defaultStr: 1) == 1;

    ///1未签，2、3已签
    double width = (Get.width - 16 * 2 - 10 * 6) / 5;
    var borderRadius = BorderRadius.all(Radius.circular(6));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(missionName, style: TextStyle(color: AppPalette.hint, fontSize: 10)),
        Spacing.h4,
        Stack(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MoneyIcon(type: '珊瑚'),
                        Spacing.h4,
                        Text(mcoinAmount, style: TextStyle(color: AppPalette.dark, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (giftUrl.isNotEmpty)
                    Container(
                      width: width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AvatarView(
                            url: giftUrl,
                            size: 32,
                            side: BorderSide(
                              width: 0.5,
                              color: AppPalette.hint,
                            ),
                          ),
                          Spacing.h4,
                          Text(giftName, style: TextStyle(color: AppPalette.dark, fontSize: 12)),
                        ],
                      ),
                    ),
                  if (freebiesUrl.isNotEmpty)
                    Container(
                      width: width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AvatarView(
                            url: freebiesUrl,
                            size: 32,
                            side: BorderSide(
                              width: 0.5,
                              color: AppPalette.hint,
                            ),
                          ),
                          Spacing.h4,
                          Text(freebiesName, style: TextStyle(color: AppPalette.dark, fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Positioned.fill(
                child: canSign
                    ? SizedBox()
                    : Container(
                        decoration: BoxDecoration(
                          color: Color(0x807C66FF),
                          borderRadius: borderRadius,
                        ),
                        padding: EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0x807C66FF),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Center(
                              child: Image.asset(
                            IMG.$('check'),
                            width: 32,
                            height: 32,
                            fit: BoxFit.fill,
                            color: Colors.white,
                          )),
                        ),
                      )),
          ],
        )
      ],
    );
  }

  showSignItem() {
    var child = signIn(true);
    return widget.showSign
        ? child
        : showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => child,
          );
  }

  ///签到
  onSignTap() {
    simpleSub(Api.Task.sign(), callback: () {
      Get.back();
      Bus.fire(CoinChangeEvent());
      if (!widget.showSign) {
        _weekKey.currentState.doRefresh();
      }
    }, msg: '签到成功');
  }
}
