import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/safe/bind_phone.dart';
import 'package:app/ui/mine/safe/change_page.dart';
import 'package:app/ui/mine/safe/forget_page.dart';
import 'package:app/ui/mine/service/servic_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class SafePage extends StatefulWidget {
  @override
  _SafePageState createState() => _SafePageState();
}

class _SafePageState extends State<SafePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('账户与安全'),
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16, top: 10),
        child: Column(
          children: <Widget>[
            _ActionView(),
          ],
        ),
      ),
    );
  }
}

class _ActionView extends StatefulWidget {
  @override
  __ActionViewState createState() => __ActionViewState();
}

class __ActionViewState extends State<_ActionView> {
  final _divider = PreferredSize(
    child: Divider(height: 1, indent: 32, endIndent: 32),
    preferredSize: Size.fromHeight(1),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OAuthCtrl.use(builder: (user) {
      String phone = xMapStr(
        user,
        'phone',
      );
      phone = xPhoneStr(phone);
      final tipDatas = {
        '换绑手机号': phone,
      };
      var data = [
        [
          '换绑手机号',
          '修改密码',
          '重置密码',
          '注销账号',
        ],
      ];
      final items = data.map((it) {
        final items = it
            .map((it) => TableItem(title: it, tips: tipDatas[it], onTap: () => onItemClick(it)))
            .toList(growable: false);

        return TableGroup(
          items,
          margin: EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          backgroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 14, color: AppPalette.dark),
          createDivider: () => _divider,
        );
      }).toList(growable: false);

      return TableView(items, spacing: 10, itemExtent: 64);
    });
  }

  void onItemClick(String item) async {
    switch (item) {
      case '换绑手机号':
        Get.to(BindPhonePage());
        break;
      case '修改密码':
        Get.to(ChangePasswordPage());
        break;
      case '重置密码':
        Get.to(ForgetPasswordPage());
        break;
      case '注销账号':
        await Get.alertDialog('注销账号功能请联系官方客服');
        Get.to(ServicPage());
        break;
    }
  }
}
