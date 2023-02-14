import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_rx/get_rx.dart';

import 'dialog/dialog.dart';

class WalletWithdrawPage extends StatefulWidget {
  Map payGold;

  WalletWithdrawPage(this.payGold);

  @override
  _WalletWithdrawPageState createState() => _WalletWithdrawPageState();
}

class _WalletWithdrawPageState extends State<WalletWithdrawPage> {
  RxMap payTypes;

  RxString payType = '支付宝'.obs;

  final _key = GlobalKey<XFutureBuilderState>();

  Future<Map> getFinancialAccount() {
    return Api.User.getFinancialAccount();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List> getChargeData() {
    return Api.User.getFindList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('提现'),
      backgroundColor: AppPalette.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 36),
            child: Column(
              children: [
                Text('${xMapStr(widget.payGold, 'diamondNum', defaultStr: 0) * 0.01}元',
                    style: TextStyle(color: AppPalette.primary, fontSize: 30, fontWeight: fw$SemiBold)),
                Text('提现金额', style: TextStyle(color: AppPalette.dark, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              child: XFutureBuilder<Map>(
                key: _key,
                futureBuilder: getFinancialAccount,
                emptyType: TipsType.noSearch,
                onData: (data) {
                  payTypes = {
                    '支付宝': {
                      '收款人名称': TextEditingController()..text = xMapStr(data, 'alipayAccountName', defaultStr: ''),
                      '收款账号': TextEditingController()
                        ..text = xMapStr(data, 'alipayAccount', defaultStr: '${OAuthCtrl.obj.phone}'),
                      '收款二维码': xMapStr(data, 'alipayAccountUrl', defaultStr: ''),
                    },
                    '微信': {
                      '收款人名称': TextEditingController()..text = xMapStr(data, 'alipayAccountName', defaultStr: ''),
                      '收款账号': TextEditingController()
                        ..text = xMapStr(data, 'wxOpenId', defaultStr: '${OAuthCtrl.obj.phone}'),
                      '收款二维码': xMapStr(data, 'wxUrl', defaultStr: ''),
                    },
                    '银行卡': {
                      '收款卡号': TextEditingController()..text = xMapStr(data, 'bankCard', defaultStr: ''),
                      '收款人姓名': TextEditingController()..text = xMapStr(data, 'bankCardName', defaultStr: ''),
                      '收款人开户行': TextEditingController()..text = xMapStr(data, 'bankName', defaultStr: ''),
                      '银联二维码': xMapStr(data, 'bankCardUrl', defaultStr: ''),
                    },
                  }.obs;
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: SingleChildScrollView(
                          child: Obx(() {
                            var datas = payTypes[payType];
                            return Column(
                              children: <Widget>[
                                _tab2('选择提现方式', '使用过的提现账号资料将保留', Color(0xffCBC8DC)),
                                SizedBox(height: 21),
                                InkWell(
                                  onTap: () => Get.showBottomSheet(QuitDialog((e) => payType.value = e)),
                                  child: Row(
                                    children: <Widget>[
                                      SvgPicture.asset(SVG.$('mine/wallet/$payType')),
                                      SizedBox(width: 16),
                                      Text('$payType', style: TextStyle(fontSize: 16, fontWeight: fw$SemiBold)),
                                      Spacing(),
                                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xffCBC8DC)),
                                    ],
                                  ).toWarp(
                                    padding: EdgeInsets.all(20),
                                    color: Color(0xffF8F7FC),
                                    radius: 12,
                                  ),
                                ),
                                SizedBox(height: 21),
                                _tab2('提现资料', '信息完善程度会影响最终到账时间', Color(0xff7C66FF)),
                                SizedBox(height: 21),
                                ...datas.keys.map((key) => dataView(key, datas[key])).toList(),
                                SizedBox(height: 80),
                              ],
                            );
                          }),
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: Text(
                            '保存并提现',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ).toBtn(40, AppPalette.primary, margin: EdgeInsets.symmetric(horizontal: 50), onTap: onSub))
                    ],
                  );
                },
                tipsSize: 300,
              ),
            ),
          )
        ],
      ),
    );
  }

  dataView(String label, dynamic data) {
    Widget widget = Container();
    if (data is TextEditingController) {
      widget = TextField(
        maxLines: 1,
        controller: data,
        inputFormatters: [LengthLimitingTextInputFormatter(50)],
        style: TextStyle(color: AppPalette.dark, fontSize: 16, height: 1),
        decoration: InputDecoration(
          hintText: '请输入$label',
          hintStyle: TextStyle(color: AppPalette.tips, fontSize: 16),
          border: InputBorder.none,
        ),
      ).toWarp(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        color: Color(0xffF8F7FC),
        radius: 12,
      );
    } else if (data is String) {
      if (data == '') {
        widget = Row(
          children: [
            SvgPicture.asset(SVG.$('mine/wallet/添加')),
            Text('请添加$label',
                style: TextStyle(
                  fontSize: 16,
                  color: AppPalette.tips,
                ))
          ],
        ).toWarp(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          color: Color(0xffF8F7FC),
          radius: 12,
        );
      } else {
        widget = Material(
          color: Color(0xffF8F7FC),
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 343 / 200,
                child: NetImage(data, fit: BoxFit.cover),
              ),
            ),
          ),
        );
      }
      widget = InkWell(
          onTap: () {
            imagePicker(
              (file) {
                simpleSub(
                  () async {
                    final url = await FileApi.upLoadFile(file, 'wallet/');
                    payTypes[payType.value][label] = url;
                    payTypes.refresh();
                  },
                );
              },
              max: 512,
            );
          },
          child: widget);
    }
    widget = Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: widget,
    );
    return widget;
  }

  _tab2(String text1, String text2, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$text1', style: TextStyle(fontSize: 16, fontWeight: fw$SemiBold)),
        Text('$text2', style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }

  ///提现
  onSub() {
    String pid = widget.payGold['cashProdId'];
    Function wallet = null;
    if (payType.value == '支付宝' || payType.value == '微信') {
      String name = (payTypes[payType.value]['收款人名称'] as TextEditingController).text.trim();
      String account = (payTypes[payType.value]['收款账号'] as TextEditingController).text.trim();
      String url = payTypes[payType.value]['收款二维码'];
      if (name == '') {
        showToast('请输入收款人名称');
        return;
      }
      if (account == '') {
        showToast('请输入收款账号');
        return;
      }
      //todo 去掉收款二维码限制

      // if (url == '') {
      //   showToast('请上传收款二维码');
      //   return;
      // }
      wallet = (code) async {
        await Api.User.bindWithdrawAccount(accountName: name, account: account, accountUrl: url, accountType: '1');
        final data = await Api.User.withDrawCashv2(pid, payType.value == '支付宝' ? '1' : '2', code);
      };
    } else if (payType.value == '银行卡') {
      String crad = (payTypes[payType.value]['收款卡号'] as TextEditingController).text.trim();
      String name = (payTypes[payType.value]['收款人姓名'] as TextEditingController).text.trim();
      String bank = (payTypes[payType.value]['收款人开户行'] as TextEditingController).text.trim();
      String url = payTypes[payType.value]['银联二维码'];
      if (crad == '') {
        showToast('请输入收款卡号');
        return;
      }
      if (name == '') {
        showToast('请输入收款人名称');
        return;
      }
      if (bank == '') {
        showToast('请输入收款人开户行');
        return;
      }
      //todo 去掉收款二维码限制
      // if (url == '') {
      //   showToast('请上传银联二维码');
      //   return;
      // }

      wallet = (code) async {
        await Api.User.bindWithdrawAccount(
            accountName: name, account: crad, bankName: bank, accountUrl: url, accountType: '3');
        final data = await Api.User.withDrawCashv2(pid, '3', code);
      };
    }

    if (wallet != null) {
      String phone = OAuthCtrl.obj.phone;
      simpleSub(Api.OAuth.certifySms(phone), msg: null, callback: () async {
        final String code = await holderProgress(Get.showInputDialog(
          title: '已发送短信至$phone',
          keyboardType: TextInputType.number,
        ));
        if (code != null && code != "") {
          simpleSub(wallet(code), msg: '提现已提交审核，请耐心等待客服处理！', callback: () {
            Get.find<WalletCtrl>().doRefresh();

            Get.back();
          });
        }
      });
    }
  }
}
