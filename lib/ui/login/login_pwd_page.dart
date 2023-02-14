import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/screen.dart';
import 'package:app/ui/login/forget_item.dart';
import 'package:app/ui/login/login_input_item.dart';
import 'package:app/ui/mine/service/servic_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/inputformatter/TextInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPwdPage extends StatefulWidget {
  @override
  _LoginPwdPageState createState() => _LoginPwdPageState();
}

class _LoginPwdPageState extends State<LoginPwdPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    phoneController.text = OAuthCtrl.obj.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(''),
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: Get.height - 60 - Screen.topBarHeight),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 50, left: 16, right: 16),
                    width: double.infinity,
                    child: loginView(),
                  ),
                  Positioned(top: 10, width: 80, height: 80, child: logo()),
                ],
              ),
            ),
            xTermsOfServiceWidget(),
          ],
        ),
      ),
    );
  }

  Widget logo() {
    return Container(
      alignment: Alignment.topCenter,
      child: Image.asset(IMG.$('acount','jpg'), scale: 3),
    );
  }

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

  Widget loginView() {
    return Column(
      children: [
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SizedBox(height: 50),
              Text('手机号登陆', style: TextStyle(fontSize: 20, color: AppPalette.dark, fontWeight: FontWeight.w600)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 6),
                child: Text('未注册手机号的用户验证后将自动创建账户',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppPalette.tips)),
              ),
              SizedBox(height: 25),
//        验证码.svg
              LoginInputItem(
                '手机号',
                '请输入手机号',
                phoneController,
                inputFormatters: [LengthLimitingTextInputFormatter(11), OnlyInputNumberAndWorkFormatter()],
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 25),
              LoginInputItem(
                '密码',
                '请输入密码',
                verifyCodeController,
                obscureText: true,
              ),
//          LoginInputItem('验证码', '请输入验证码', verifyCodeController, actions: [
//            SMSCodeView(
//              phoneController.text,),
//          ]),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '同意协议并登陆',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 13, color: Colors.white)
                ],
              ).toBtn(
                60,
                AppPalette.hint,
                margin: EdgeInsets.only(left: 48, right: 48, bottom: 30),
                colors: [Color(0xffA882FF), Color(0xff645BFF)],
                onTap: () => doLogin(),
              ),
            ],
          ),
        ),
        ForgetItem(),
      ],
    );
  }

  doLogin() {
    String phone = phoneController.text.trim(), code = verifyCodeController.text.trim();
    if (phone == null || phone.isEmpty || code == null || code.isEmpty) {
      showToast('账号密码不能为空');
      return;
    }

    simpleSub(OAuthCtrl.obj.doPwdLogin(phone, code), whenErr: {
      407: (e) async {
        await Get.alertDialog(e.msg);
        Get.to(ServicPage());
      }
    });
  }
}
