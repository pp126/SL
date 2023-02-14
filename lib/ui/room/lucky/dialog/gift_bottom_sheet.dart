import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GiftBottomSheet extends GetWidget<WalletCtrl> {
  final int drawType;

  GiftBottomSheet(this.drawType);

  Future<List> getData() {
    final api = drawType == 0 ? Api.User.getPrizePoolGift : Api.User.getMaxPrizePoolGift;

    return api();
  }

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
            child: Text('物资储备', style: TextStyle(fontSize: 16, color: AppPalette.txtWhite, fontWeight: fw$SemiBold)),
          ),
          Expanded(
            child: XFutureBuilder<List>(
                futureBuilder: getData,
                onData: (list) {
                  return SingleChildScrollView(
                    child: GridLayout(
                      padding: EdgeInsets.all(10),
                      children: [for (Map data in list) xitme(data)],
                      crossAxisCount: 4,
                      childAspectRatio: 78 / 102,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  xitme(Map data) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: <Widget>[
            NetImage(data['giftUrl'], width: 40, height: 40, fit: BoxFit.fill),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MoneyIcon(size: 14),
                Text('${xMapStr(data, 'goldPrice', defaultStr: '0')}',
                    style: TextStyle(fontSize: 10, color: Color(0xffFFCB2F))),
              ],
            ),
            Text('${xMapStr(data, 'giftName', defaultStr: '')}',
                style: TextStyle(fontSize: 10, color: AppPalette.txtWhite)),
            Text('${xMapStr(data, 'probability', defaultStr: '0')}',
                style: TextStyle(fontSize: 10, color: Color(0xffFF607C))),
          ].separator(Spacing.h2),
        ),
      ),
    ).toWarp(radius: 12, color: Color(0xff191535));
  }
}
