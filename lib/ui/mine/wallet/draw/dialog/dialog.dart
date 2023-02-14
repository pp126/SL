import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PermuteDialog extends StatelessWidget {
  double goldNum;

  PermuteDialog(this.goldNum);

  TextEditingController controller = TextEditingController.fromValue(TextEditingValue(
      text: '0', selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: 0))));
  RxString text = ''.obs;
  FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    focusNode = FocusNode();
    controller.text = '${goldNum.toInt()}';
    text.value = '${goldNum.toInt()}';
    return GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                  onTap: () => null,
                  child: Container(
                      height: 325,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(18), topLeft: Radius.circular(18)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      child: Obx(() {
                        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('兑换海星',
                                style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: FontWeight.w600)),
                            IconButton(
                                icon: Icon(Icons.clear, size: 30, color: Color(0xff252142)),
                                onPressed: () => Get.back())
                          ]),
                          Text('当前珍珠：$goldNum', style: TextStyle(color: Color(0xff908DA8), fontSize: 16)),
                          SizedBox(height: 15),
                          Align(
                                  alignment: Alignment.topCenter,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Image.asset(IMG.$('珍珠'), scale: 3),
                                    SizedBox(
                                      width: text.value.length * 14.0,
                                      child: TextField(
                                        autofocus: true,
                                        maxLines: 1,
                                        focusNode: focusNode,
                                        textAlign: TextAlign.center,
                                        controller: controller,
                                        onChanged: (str) {
                                          final oldText = str;
                                          final newText = int.parse(str).toString();
                                          if (oldText != newText) {
                                            controller.text = text.value = int.parse(str).toString();
                                            controller.selection = TextSelection.collapsed(offset: text.value.length);
                                            text.value = newText;
                                          } else
                                            text.value = oldText;
                                        },
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                                        style: TextStyle(color: AppPalette.dark, fontSize: 16, height: 1),
                                        decoration: InputDecoration(border: InputBorder.none),
                                      ),
                                    )
                                  ]))
                              .toBtn(60, Color(0xffF8F7FC),
                                  onTap: () => FocusScope.of(context).requestFocus(focusNode)),
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Image.asset(IMG.$('海星'), scale: 3),
                              SizedBox(
                                  width: text.value.length * 14.0,
                                  child: Text(text.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xff7C66FF), fontSize: 16)))
                            ]),
                          ),
                          SizedBox(height: 30),
                          Text('立即转换', maxLines: 1, style: TextStyle(color: Colors.white))
                              .toBtn(40, Color(0xff7C66FF), width: 275, onTap: doSub),
                          SizedBox(height: 30),
                        ]);
                      })))),
        ));
  }

  doSub() {
    final count = int.parse(controller.text);
    if (count <= 0) {
      showToast('请输入要转换的珍珠数量！');
      return;
    }
    simpleSub(Api.User.exchangeGold(count), msg: '兑换成功', callback: () {
      Bus.send(CMD.gold_change, count);
      Bus.send(CMD.diamond_change, -count);
      Get.back();
    });
  }
}

class QuitDialog extends StatelessWidget {
  final onTap;
  final pays = {'支付宝': '支付宝 - 推荐', '微信': '微信', '银行卡': '银行卡'};

  QuitDialog(this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 325,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
              children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('提现方式', style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                  icon: Icon(Icons.clear, size: 30, color: Color(0xff252142)),
                  onPressed: () {
                    Get.back();
                  })
            ]),
            ...pays.keys
                .map((e) => InkWell(
                      onTap: () {
                        onTap(e);
                        Get.back();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(SVG.$('mine/wallet/$e')),
                          SizedBox(width: 16),
                          Text('${pays[e]}', style: TextStyle(fontSize: 14, fontWeight: fw$SemiBold)),
                        ],
                      ).toWarp(
                        padding: EdgeInsets.all(20),
                        color: Color(0xffF8F7FC),
                        radius: 12,
                      ),
                    ))
                .toList()
          ].separator(SizedBox(height: 10))),
        ));
  }
}
