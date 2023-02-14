import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/audit_ctrl.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/wallet/draw/wallet_withdraw_page.dart';
import 'package:app/ui/mine/wallet/pay/wallet_pay_page.dart';
import 'package:app/ui/mine/wallet/wallet_list_page.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';

import 'draw/dialog/dialog.dart';
import 'draw/wallet_draw_page.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final tabs = {'海星': 'goldNum', '珊瑚': 'mcoinNum', '珍珠': 'diamondNum'};

  final WalletCtrl walletCtrl = Get.find();

  @override
  void initState() {
    super.initState();

    walletCtrl.doRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '我的钱包',
        action: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppPalette.txtDark),
            onPressed: walletCtrl.doRefresh,
          ),
          'mine/流水记录'.toSvgActionBtn(onPressed: () => Get.to(WalletListPage())),
        ],
      ),
      backgroundColor: AppPalette.background,
      body: Stack(
        children: [
          WalletCtrl.useAllGold(builder: (data, _, __) {
            return Column(
              children: tabs.entries //
                  .map<Widget>((it) => xTab(it.key, data[it.value] ?? 0))
                  .toList(growable: false),
            );
          }),
          _bottom(),
          _withdraw(),
        ],
      ),
    );
  }

  xTab(String key, num price) {
    Widget tab = Row(children: [
      Expanded(
        child: Text(
          '我的$key',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      MoneyIcon(size: 20, type: key),
      SizedBox(width: 5),
      Text(
        '$price',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff7C66FF)),
      )
    ]);
    if (key == '珍珠') {
      tab = Column(
        children: [
          tab,
          SizedBox(height: 11),
          AppTextButton(
            width: double.infinity,
            height: 40,
            bgColor: AppPalette.txtWhite,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            title: Text(
              '兑换海星',
              style: TextStyle(
                  fontSize: 14,
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w600),
            ),
            onPress: () {
              final _ctrl = walletCtrl;

              context.showDownDialog(
                PermuteDialog(_ctrl.value['diamondNum'] ?? 0.0),
              );
            },
          ),
        ],
      );
    }

    return tab.toWarp(
      color: Colors.white,
      radius: 12,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: EdgeInsets.all(20),
    );
  }

  Widget _bottom() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 100,
      child: AppTextButton(
        width: double.infinity,
        height: 40,
        bgColor: AppPalette.primary,
        margin: EdgeInsets.symmetric(horizontal: 50),
        borderRadius: BorderRadius.circular(20),
        title:
            Text('充值海星', style: TextStyle(fontSize: 14, color: Colors.white)),
        onPress: () async {
          // flutter 原生支付
          // Get.to(WalletPayPage());

          // 临时注销
          if (GetPlatform.isIOS && AuditCtrl.obj.isAudit) {
            Get.to(WalletPayPage());
          } else {
            simpleSub(
              () async {
                final url = await Api.Wx.getWxH5ChargeUrl();

                final myUid = OAuthCtrl.obj.uid;

                int roomUid;

                try {
                  roomUid = RoomCtrl.obj.roomUid;
                } catch (e) {
                  //ignore
                }

                Get.to(AppWebPage(
                    title: '充值海星',
                    url:
                        '$url?uid=$myUid&isWebView=1&roomUid=$roomUid&client=1'));
              },
              msg: null,
            );
          }
        },
      ),
    );
  }

  Widget _withdraw() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 40,
      child: AppTextButton(
        width: double.infinity,
        height: 40,
        bgColor: AppPalette.primary,
        margin: EdgeInsets.symmetric(horizontal: 50),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        title: Text(
          '提现',
          style: TextStyle(fontSize: 14, color: AppPalette.txtWhite),
        ),
        onPress: () async {
          Get.to(WalletDrawPage());
        },
      ),
    );
  }
}
