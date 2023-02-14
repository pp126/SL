import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/room/lucky/dialog/dialog.dart';
import 'package:app/ui/room/lucky/dialog/pay_bottom_sheet.dart';
import 'package:app/ui/room/lucky/dialog/rank_bottom_sheet.dart';
import 'package:app/ui/room/lucky/dialog/record_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../lucky_record.dart';
import 'gift_bottom_sheet.dart';

class LuckyBottomSheet extends StatefulWidget {
  final int roomID;
  final List types;
  int drawType = 0;

  LuckyBottomSheet(this.roomID, this.types);

  @override
  _LuckyBottomSheetState createState() => _LuckyBottomSheetState();
}

class _LuckyBottomSheetState extends State<LuckyBottomSheet>
    with SingleTickerProviderStateMixin {
  Map tabs;
  TabController ctrl;
  int coins;
  int coinsMax;

  Future<Map> getConfig() {
    Api.Home.getConfig().then((value) => setState(() {
          coins = value['drawGold'];
          coinsMax = value['maxDrawGold'];
        }));
  }

  @override
  void initState() {
    super.initState();
    final types = widget.types;

    getConfig();

    tabs = {
      if (types.contains(0)) '普通宝箱': 0,
      if (types.contains(1)) '高级宝箱': 1,
    };

    ctrl = TabController(length: tabs.length, vsync: this);
    ctrl.addListener(() {
      switch (ctrl.index) {
        case 0:
          widget.drawType = 0;
          break;
        case 1:
          widget.drawType = 1;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      child: Column(
        children: [
          Spacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                child: TabBar(
                  controller: ctrl,
                  isScrollable: true,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3, color: AppPalette.primary),
                    insets: EdgeInsets.symmetric(horizontal: 36),
                  ),
                  tabs: tabs.entries //
                      .map((it) => Tab(text: it.key))
                      .toList(growable: false),
                ),
              ),
              FloatingActionButton(
                child: Text(
                  '规则(爆率)',
                  style: TextStyle(fontSize: 14, color: Color(0xff5B5290)),
                ),
                onPressed: () {
                  return Get.showBottomSheet(
                    RuleDialog(widget.drawType),
                    bgColor: Color(0xff363059),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: ctrl,
              children: tabs.entries //
                  .map((it) => _LuckyView(
                        roomID: widget.roomID,
                        drawType: it.value,
                        coins: it.value == 1 ? coinsMax : coins,
                      ))
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyView extends StatelessWidget {
  final int drawType;
  final int roomID;
  final int coins;

  _LuckyView({this.drawType, this.roomID, this.coins}) {}

  @override
  Widget build(BuildContext context) {
    final moneyView = IntrinsicWidth(
      child: InkWell(
        child: Container(
          height: 32,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration:
              ShapeDecoration(color: Color(0xff363059), shape: StadiumBorder()),
          child: Row(
            children: [
              // MoneyIcon(type: '钥匙_$drawType', size: 20),
              MoneyIcon(type: '海星', size: 20),
              Spacing.w4,
              GetX<WalletCtrl>(
                builder: (it) {
                  // final num = it.value[drawType == 0 ? 'conchNum' : 'maxConchNum'];
                  final num = it.value['goldNum'];

                  return Text(
                    '${num ?? 0}',
                    style: TextStyle(
                        fontSize: 16,
                        color: AppPalette.primary,
                        fontWeight: fw$SemiBold),
                  );
                },
              ),
            ],
          ),
        ),
        onTap: () => Get.showBottomSheet(PayBottomSheet(drawType),
            bgColor: AppPalette.sheetDark),
      ),
    );

    final bodyView = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset(IMG.$('宝箱_$drawType'), width: 156, scale: 2),
        Column(
          children: [
            $Btn(
              title: '开1次',
              width: 122,
              height: 40,
              bg: Color(0xff363059),
              textStyle: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(4), right: Radius.circular(20)),
              ),
              onTap: () => doSub(context, 1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: $Btn(
                title: '开10次',
                width: 124,
                height: 40,
                bg: Color(0xff695CB5),
                textStyle: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4), right: Radius.circular(20)),
                ),
                onTap: () => doSub(context, 10),
              ),
            ),
            $Btn(
              title: '开100次',
              width: 122,
              height: 40,
              bg: Color(0xff7C66FF),
              textStyle: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(4), right: Radius.circular(20)),
              ),
              onTap: () => doSub(context, 100),
            ),
          ].separator(SizedBox(height: 10)),
        )
      ],
    );

    final actionView = Row(
      children: <Widget>[
        Expanded(
          child: $Btn(
            title: '物资储备',
            height: 36,
            bg: Color(0xff363059),
            textStyle: TextStyle(fontSize: 14, color: Color(0xff9A93C2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            onTap: () => Get.showBottomSheet(GiftBottomSheet(drawType),
                bgColor: AppPalette.sheetDark),
          ),
        ),
        Expanded(
          child: $Btn(
            title: '收集记录',
            height: 36,
            bg: Color(0xff363059),
            textStyle: TextStyle(fontSize: 14, color: Color(0xff9A93C2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            onTap: () => Get.showBottomSheet(RecordBottomSheet(drawType),
                bgColor: AppPalette.sheetDark),
          ),
        ),
        Expanded(
          child: $Btn(
            title: '每日榜单',
            height: 36,
            bg: Color(0xff363059),
            textStyle: TextStyle(fontSize: 14, color: Color(0xff9A93C2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            onTap: () => Get.showBottomSheet(RankBottomSheet(drawType),
                bgColor: AppPalette.sheetDark),
          ),
        ),
      ].separator(Spacing.w10),
    );

    return Column(
      children: [
        Spacing.h16,
        moneyView,
        Spacing.h32,
        bodyView,
        Spacing.h16,
        Spacing.exp,
        Text(
          '消耗海星抽奖，金币通过充值获得',
          style: TextStyle(color: AppPalette.tips, fontSize: 14),
        ),
        Spacing.exp,
        Text(
          '消耗${coins}海星抽1次',
          style: TextStyle(color: AppPalette.primary, fontSize: 14),
        ),
        Spacing.exp,
        Spacing.h16,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: actionView,
        ),
        Spacing.h16,
        Spacing.exp,
      ],
    );
  }

  void doSub(BuildContext context, int count) {
    int type;
    switch (count) {
      case 1:
        type = 1;
        break;
      case 10:
        type = 2;
        break;
      case 50:
        type = 4;
        break;
      case 100:
        type = 5;
        break;
      default:
        return;
    }

    final api = Api.Draw.roomDraw(roomID, type, drawType);

    simpleSub(
      api,
      msg: null,
      isShowProgress: false,
      callback: () async {
        final result = await api;

        Bus.send(CMD.conch_change, Tuple2(drawType, -count));
        Bus.send(CMD.gold_change, -(count * coins));

        final List giftList = result['giftList'];

        if (!giftList.isBlank) {
          final first = giftList.first;

          if (giftList.length == 1 && first['giftNum'] == 1) {
            showGift(context, first);
          } else {
            Get.dialog(
                GiftDialog(count, giftList, () => doSub(context, count)));
          }
        }
      },
      whenErr: {
        2107: (_) => Get.showBottomSheet(
            PayBottomSheet(drawType, loadCount: count),
            bgColor: AppPalette.sheetDark)
      },
    );
  }

  showGift(BuildContext context, Map data) {
    final overlayState = Overlay.of(context);

    final overlayEntry = OverlayEntry(builder: (_) {
      return Positioned(
        top: Get.height - 520 - Get.bottomBarHeight / Get.pixelRatio,
        child: Container(
          width: Get.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: data == null ? SizedBox.shrink() : giftItem(data),
          ),
        ),
      );
    });

    overlayState.insert(overlayEntry..markNeedsBuild());

    Future.delayed(Duration(milliseconds: 1500))
        .then((value) => overlayEntry.remove());
  }

  giftItem(Map data) {
    return Card(
      color: Color(0xff191535),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
          children: [
            NetImage(
              data['picUrl'],
              width: 40,
              height: 40,
              fit: BoxFit.fill,
            ),
            Spacing.w10,
            Expanded(
              child: Text(
                '${data['giftName']}',
                style: TextStyle(fontSize: 10, color: AppPalette.txtWhite),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MoneyIcon(size: 14),
                Text(
                  '${data['goldPrice']}',
                  style: TextStyle(fontSize: 10, color: Color(0xffFFCB2F)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
