import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/wallet/draw/wallet_draw_list_page.dart';
import 'package:app/ui/mine/wallet/draw/wallet_withdraw_page.dart';
import 'package:app/ui/mine/wallet/wallet_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class WalletDrawPage extends StatefulWidget {
  @override
  _WalletDrawPageState createState() => _WalletDrawPageState();
}

class _WalletDrawPageState extends State<WalletDrawPage> {
  List<dynamic> payGolds = List();
  Map payGold;

  @override
  void initState() {
    super.initState();
  }

  Future<List> getChargeData() {
    return Api.User.getFindList();
  }

  @override
  Widget build(BuildContext context) {
    String money = '请选择提现数量';
    payGolds.forEach((element) {
      if (element['check'] != null && element['check']) {
        payGold = element;
        money = '确定提现${element['diamondNum'] * 0.1}元';
      }
    });

    return Scaffold(
      appBar: xAppBar('提现',
          action: InkWell(
            onTap: () => Get.to(WalletDrawListPage()),
            child: Row(
              children: [
                Icon(
                  Icons.menu,
                  color: Color(0xff7C66FF),
                  size: 20,
                ),
                Spacing.w4,
                Text(
                  '提现记录',
                  style: TextStyle(color: Color(0xff7C66FF), fontSize: 14),
                ),
                Spacing.w8,
              ],
            ),
          )),
      backgroundColor: AppPalette.background,
      body: Column(
        children: <Widget>[
          WalletItem(
            showGold: false,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '请选择提现金额',
                          style: TextStyle(
                              color: AppPalette.dark,
                              fontSize: 16,
                              fontWeight: fw$SemiBold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        XFutureBuilder<List>(
                            futureBuilder: getChargeData,
                            onData: (data) {
                              payGolds = data;
                              return Column(
                                children:
                                    payGolds.map(xItem).toList(growable: false),
                              );
                            }),
                        SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Spacer(),
                      Text(
                        money,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ).toBtn(40, AppPalette.primary,
                          margin: EdgeInsets.symmetric(horizontal: 34),
                          onTap: onPayTap),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        '全部提现',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ).toBtn(40, AppPalette.primary,
                          margin: EdgeInsets.symmetric(horizontal: 34),
                          onTap: onPayTap)
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget xItem(dynamic item) {
    return Row(
      children: [
        MoneyIcon(type: '珍珠'),
        Spacing.w4,
        Text(item['cashProdName'],
            style: TextStyle(color: AppPalette.primary, fontSize: 14)),
        Expanded(
            child: Text(
          '${item['diamondNum'] * 0.1}元',
          textAlign: TextAlign.right,
          style: TextStyle(color: AppPalette.dark, fontSize: 14),
        )),
        SizedBox(width: 15),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(width: 1, color: AppPalette.hint),
          ),
          child: item['check'] ?? false
              ? Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppPalette.primary,
                  ),
                )
              : Container(),
        )
      ],
    ).toBtn(
      60,
      AppPalette.divider,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      radius: 12,
      onTap: () {
        payGolds.forEach((element) {
          element['check'] = false;
        });
        item['check'] = true;
        setState(() {});
      },
    );
  }

  ///提现
  onPayTap() {
    if (payGold == null || payGold.isEmpty) {
      showToast('请选择提现的金额');
      return;
    }
    Get.to(WalletWithdrawPage(payGold));
  }

  ///提现
  onPayTapAll() {
    Get.to(WalletWithdrawPage(payGold));
  }
}
