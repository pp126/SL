import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/wallet/wallet_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../lucky_record.dart';

class PayBottomSheet extends GetWidget<WalletCtrl> {
  final int unit;
  final int drawType;
  final RxInt count;
  final TextEditingController numCtl;

  PayBottomSheet(this.drawType, {int loadCount = 1})
      : count = loadCount.obs,
        assert(drawType == 0 || drawType == 1),
        unit = drawType == 0 ? 200 : 2000,
        numCtl = TextEditingController(text: '$loadCount');

  final textCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text('全服播报', style: TextStyle(fontSize: 16, color: AppPalette.txtWhite, fontWeight: fw$SemiBold)),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('消耗：', style: TextStyle(color: Color(0xff908DA8), fontSize: 16)),
                  MoneyIcon(size: 22),
                  Obx(
                    () => Text(
                      '${count.value * unit}',
                      style: TextStyle(fontSize: 14, color: Color(0xffFFCB2F)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('获赠：', style: TextStyle(color: Color(0xff908DA8), fontSize: 16)),
                  MoneyIcon(type: '钥匙_$drawType', size: 22),
                  Obx(
                    () => Text(
                      '${count.value}',
                      style: TextStyle(fontSize: 14, color: Color(0xff7C66FF)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 44,
          child: TextField(
            maxLines: 1,
            textAlign: TextAlign.start,
            controller: textCtl,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            style: TextStyle(color: Color(0xffCBC8DC).withOpacity(0.3), fontSize: 16, height: 1),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '让我们交个朋友吧...',
              hintStyle: TextStyle(color: Color(0xffCBC8DC).withOpacity(0.3), fontSize: 16, height: 1),
            ),
          ),
        ).toWarp(
          color: Color(0xff353056),
          margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 25),
          padding: EdgeInsets.symmetric(horizontal: 25),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18, right: 16),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Get.to(WalletPage()),
                  child: Row(
                    children: [
                      Text('拥有：', style: TextStyle(color: Color(0xff908DA8), fontSize: 16)),
                      MoneyIcon(size: 22),
                      WalletCtrl.useGold(builder: (goldNum) {
                        return Text(
                          '$goldNum',
                          style: TextStyle(fontSize: 14, color: Color(0xffFFCB2F)),
                        );
                      }),
                      SizedBox(width: 6),
                      Text(
                        '充值',
                        style: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
                      ),
                      Image.asset(IMG.$('查看更多'), scale: 3),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 77,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xff363059),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(4)),
                    ),
                    child: TextField(
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      controller: numCtl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      onChanged: (str) {
                        final oldText = str;
                        int num = int.parse(str);
                        final newText = num.toString();
                        if (oldText != newText) {
                          numCtl.text = '${count.value = num}';
                          numCtl.selection = TextSelection.collapsed(offset: count.value.toString().length);
                          count.value = num;
                        } else
                          count.value = num;
                      },
                      style: TextStyle(color: Color(0xffCBC8DC), fontSize: 16, height: 1),
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  SizedBox(width: 6),
                  $Btn(
                    title: '发送',
                    width: 62,
                    height: 45,
                    bg: Color(0xff7C66FF),
                    textStyle: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(20)),
                    ),
                    onTap: doSub,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 44),
      ],
    );
  }

  doSub() {
    String msg = textCtl.text.trim();
    if (msg == '') {
      msg = '让我们交个朋友吧...';
    }

    final buyNum = count.value;

    if (buyNum == 0) {
      showToast('请至少发送一个');
      return;
    }

    final api = drawType == 0 ? Api.Gift.buyBigHorn : Api.Gift.buyMaxBigHorn;

    simpleSub(api(buyNum, msg), msg: '发送成功', callback: () {
      Bus.send(CMD.conch_change, Tuple2(drawType, buyNum));

      Bus.send(CMD.gold_change, -(buyNum * unit));
    });
  }
}
