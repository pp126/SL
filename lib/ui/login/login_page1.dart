import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/login/register_phone_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'login_pwd_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: 760,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: 138, left: 16, right: 16, child: typeView()),
              Positioned(top: 50, width: 150, height: 132, child: logo()),
              Positioned(bottom: 110, left: 0, right: 0, child: otherTypeView()),
              xTermsOfServiceWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget logo() {
    return Container(
      alignment: Alignment.topCenter,
      child: Image.asset(IMG.$('login_logo','jpg'), scale: 3),
    );
  }

//  Widget logo() {
//    return Container(
//      decoration: BoxDecoration(
//        shape: BoxShape.circle,
//        border: Border.all(width: 3, color: Colors.white),
//        boxShadow: [
//          BoxShadow(color: Color(0x1F7C66FF), blurRadius: 10),
//        ],
//      ),
//      child: Image.asset(IMG.$('login_logo'), scale: 3),
//    );
//  }

  Widget otherTypeView() {
    final data = ['微信', 'QQ', '苹果'];

    Widget btn(title) {
      return GestureDetector(
        child: Column(
          children: [
            SvgPicture.asset(SVG.$('login/$title')),
            Spacing.h8,
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppPalette.tips),
            ),
          ],
        ),
        onTap: () => true,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [for (final it in data) btn(it)],
    );
  }

  Widget typeView() {
    final data = [
      [
        AppPalette.primary,
        [
          SvgPicture.asset(SVG.$('login/本机号码一键登录'), color: Colors.white),
          Spacing.w8,
          Text('本机号码一键登录', style: TextStyle(color: Colors.white)),
        ],
        (){
          onOnceLoginTap();
        },
      ],
      [
        AppPalette.dark,
        [
          SvgPicture.asset(SVG.$('login/通过AppleID继续'), color: Colors.white),
          Spacing.w8,
          Text('通过AppleID继续', style: TextStyle(color: Colors.white)),
        ],
        () => Get.to(LoginPwdPage())
      ],
      [
        AppPalette.txtWhite,
        [
          SvgPicture.asset(SVG.$('login/使用手机号码登录')),
          Spacing.w8,
          Text('使用手机号码登录', style: TextStyle(color: AppPalette.primary)),
        ],
        () => Get.to(LoginPwdPage())
      ],
      [
        AppPalette.primary,
        [
          Spacing.w8,
          Text('注册', style: TextStyle(color: Colors.white)),
        ],
        () => Get.to(RegisterPhonePage())
      ]
    ];

    Widget btn(List data) {
      return xFlatButton(
        60,
        data[0],
        width: 238,
        margin: EdgeInsets.only(bottom: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: data[1]),
        onTap: data[2]
      );
    }

    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(height: 30),
          Text('Hello 欢迎你', style: TextStyle(fontSize: 20, color: AppPalette.dark)),
          SizedBox(height: 40),
          for (final it in data) btn(it),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  doPwdLogin() async {}

  onOnceLoginTap() async {
  }
}
