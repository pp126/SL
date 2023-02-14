import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/screen.dart';
import 'package:app/ui/login/login_input_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/sms_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPhonePage extends StatefulWidget {
  @override
  _RegisterPhonePageState createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  String sendText = '发送验证码';
  int sendNum = 0;

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
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(height: 50),
          Text('手机号注册', style: TextStyle(fontSize: 20, color: AppPalette.dark, fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 0),
            child: Text('未注册手机号的用户验证后将自动创建账户',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppPalette.tips)),
          ),
          SizedBox(height: 25),
//        验证码.svg
          LoginInputItem(
            '手机号',
            '请输入手机号',
            phoneController,
            inputFormatters: [LengthLimitingTextInputFormatter(11)],
            keyboardType: TextInputType.phone,
            onChange: (str) {
              setState(() {});
            },
          ),
          SizedBox(height: 25),
          LoginInputItem('验证码', '请输入验证码', verifyCodeController,
              inputFormatters: [LengthLimitingTextInputFormatter(5)],
              keyboardType: TextInputType.number,
              actions: [SMSCodeView(phoneController.text, SMSType.register)]),
          SizedBox(height: 25),
          LoginInputItem(
            '密码',
            '请输入6-18位密码',
            pwdController,
            inputFormatters: xPasswordFormatter(),
            obscureText: true,
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '同意协议并注册',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: Colors.white,
              )
            ],
          ).toBtn(
            60,
            AppPalette.hint,
            splashColor: AppPalette.subSplash,
            margin: EdgeInsets.only(left: 48, right: 48, bottom: 30),
            colors: [Color(0xffA882FF), Color(0xff645BFF)],
            onTap: () => doSignup(),
          ),
        ],
      ),
    );
  }

  doSignup() {
    String phone = phoneController.text.trim(),
        verify = verifyCodeController.text.trim(),
        pwd = pwdController.text.trim();

    if (phone == null || phone.isEmpty) {
      showToast('账号不能为空');
      return;
    }
    if (verify == null || verify.isEmpty) {
      showToast('验证码不能为空');
      return;
    }
    if (pwd == null || pwd.isEmpty) {
      showToast('密码不能为空');
      return;
    }
    if (pwd.length < 6 || pwd.length > 18) {
      showToast('请输入6-18位密码');
      return;
    }
    if (!CommonUtils.checkChinaPhone(phone)) {
      showToast('请输入正确的手机号码！');
      return;
    }

    simpleSub(Api.OAuth.signup(phone, verify, pwd),
        msg: null,
        callback: () => simpleSub(() async {
              await Future.delayed(Duration(seconds: 1));
              await OAuthCtrl.obj.doPwdLogin(phone, pwd);
            }));
  }
}
