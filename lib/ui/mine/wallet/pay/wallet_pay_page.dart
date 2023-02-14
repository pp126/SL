import 'dart:io';

import 'package:app/apple/in_app.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/wallet/wallet_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class WalletPayPage extends StatefulWidget {
  @override
  _WalletPayPageState createState() => _WalletPayPageState();
}

class _WalletPayPageState extends State<WalletPayPage> {
  List<dynamic> payGold = List();
  var currentType;

  @override
  void initState() {
    super.initState();
  }

  Future<List> getChargeData() {
    return Api.User.getChargeList();
  }

  @override
  Widget build(BuildContext context) {
    String money = '请选择充值数量';
    payGold.forEach((element) {
      if (element['check'] != null && element['check']) {
        currentType = element;
        money = '确定支付${xMoneyStr(currentType)}元';
      }
    });

    return Scaffold(
      appBar: xAppBar('充值'),
      backgroundColor: AppPalette.background,
      body: Column(
        children: <Widget>[
          WalletItem(
            showGift: false,
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
                          '请选择充值金额',
                          style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: fw$SemiBold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        XFutureBuilder<List>(
                            futureBuilder: getChargeData,
                            onData: (data) {
                              payGold = data;
                              return Column(
                                children: payGold.map(xItem).toList(growable: false),
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
                      ).toBtn(40, AppPalette.primary, margin: EdgeInsets.symmetric(horizontal: 34), onTap: onPayTap)
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
    String moneyStr = xMoneyStr(item);

    return Row(
      children: [
        MoneyIcon(size: 20),
        Spacing.w4,
        Text(item['prodName'], style: TextStyle(color: AppPalette.primary, fontSize: 14)),
        Expanded(
            child: Text(
          '$moneyStr元',
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
        payGold.forEach((element) {
          element['check'] = false;
        });
        item['check'] = true;
        setState(() {});
      },
    );
  }
  xMoneyStr(var item){
    double money = xMapStr(item, 'money',defaultStr: 0) / 100.0;
    String moneyStr = money.toString();
    if(money>=1){
      moneyStr = money.toInt().toString();
    }
    return moneyStr;
  }
  ///充值
  onPayTap() {
    if (currentType == null || currentType.isEmpty) {
      showToast('请选择充值的金额');
      return;
    }

    simpleSub(
        Api.User.payMoney(
          chargeProdId: xMapStr(currentType, 'chargeProdId'),
        ), callback: () {
      // doRefresh();
    }, msg: '充值成功');

    // 临时注销
    // String chargeProdId = xMapStr(currentType, 'chargeProdId');
    // if(Platform.isIOS && chargeProdId.isNotEmpty) {///内购
    //   requestPurchase(chargeProdId);
    // }else{
    //   simpleSub(
    //       Api.User.payMoney(
    //         chargeProdId: xMapStr(currentType, 'chargeProdId'),
    //       ), callback: () {
    //     doRefresh();
    //   }, msg: '充值成功');
    // }
  }
}
