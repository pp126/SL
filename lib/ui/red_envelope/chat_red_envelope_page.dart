import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ChatRedEnvelopePage extends StatelessWidget {
  final int uid;

  ChatRedEnvelopePage(this.uid);

  final inputs = {
    '单个金额': Tuple4(TextEditingController(), '输入红包数额...', TextInputType.number,
        MoneyIcon(size: 20)),
    '红包祝语': Tuple4(TextEditingController(), '恭喜发财，大吉大利！', null, null),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('发红包'),
      backgroundColor: AppPalette.background,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ...inputs.entries.map(
              (it) {
                final v = it.value;

                return $Input(
                  title: it.key,
                  ctrl: v.item1,
                  hint: v.item2,
                  type: v.item3,
                  suffix: v.item4,
                );
              },
            ).separator(Spacing.h32),
            Spacing.h32,
            WalletCtrl.useAllGold(builder: (_, num, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoneyIcon(size: 20),
                  Spacing.w4,
                  Text(
                    '$num',
                    style: TextStyle(fontSize: 18, color: AppPalette.txtDark),
                  ),
                ],
              );
            }),
            Spacing.h32,
            AppTextButton(
              width: double.infinity,
              height: 48,
              bgColor: AppPalette.primary,
              borderRadius: BorderRadius.circular(999),
              title: Text(
                '确定发送',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onPress: doSub,
            ),
          ],
        ),
      ),
    );
  }

  Widget $Input(
      {TextEditingController ctrl,
      TextInputType type,
      String hint,
      String title,
      Widget suffix}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: 0,
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(999),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: AppPalette.tips),
        prefixIcon: Container(
          width: 100,
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontSize: 13)),
        ),
        suffixIcon: Container(
          width: 56,
          alignment: Alignment.centerLeft,
          child: suffix,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      keyboardType: type,
      style: TextStyle(fontSize: 13, color: AppPalette.txtDark),
    );
  }

  void doSub() async {
    final numCtrl = inputs['单个金额'].item1;
    final txtCtrl = inputs['红包祝语'].item1;

    int num = 0;

    try {
      num = int.parse(numCtrl.text);
    } catch (e) {
      // ignore
    }

    if (num <= 0) {
      showToast('请输入正确的数量');

      return;
    }

    String remark = txtCtrl.text;

    if (remark.isNullOrBlank) {
      remark = inputs['红包祝语'].item2;
    }

    final result = await Get.simpleDialog(msg: '确定发送$num海星红包');

    if (result == '确定') {
      simpleSub(
        Api.Packet.send(uid, num, remark),
        callback: () {
          numCtrl.clear();

          Bus.send(CMD.gold_change, -num);
        },
      );
    }
  }
}
