import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_textfield.dart';
import 'package:app/widgets/sms_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isBind = false;
  bool isInput = false;
  VoidCallback listener;

  final TextEditingController phoneController = TextEditingController(text: '');
  final TextEditingController verifyCodeController = TextEditingController(text: '');
  final TextEditingController passwordController = TextEditingController(text: '');
  final TextEditingController confirmPasswordController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    initParams();
  }

  initParams() async {
    listener = () {
      checkInput();
    };

    phoneController.addListener(listener);
    verifyCodeController.addListener(listener);
    passwordController.addListener(listener);
    confirmPasswordController.addListener(listener);
  }

  checkInput() {
    setState(() {
      isInput = phoneController.text.isNotEmpty &&
          verifyCodeController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    phoneController.removeListener(listener);
    verifyCodeController.removeListener(listener);
    passwordController.removeListener(listener);
    confirmPasswordController.removeListener(listener);
    phoneController.dispose();
    verifyCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String phone = OAuthCtrl.obj.phone;
    isBind = phone.isNotEmpty && OAuthCtrl.obj.isLogin;
    if (isBind) {
      phoneController.text = phone;
      phone = xPhoneStr(phone);
    }

    return Scaffold(
      appBar: xAppBar('重置密码'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              isBind
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20, top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '当前账号 : $phone',
                        style: TextStyle(fontSize: 12, color: AppPalette.tips),
                      ),
                    )
                  : AppTextFormField(
                      controller: phoneController,
                      textInputAction: TextInputAction.next,
                      leftStr: '手机号',
                      leftWidth: 80,
                      hintText: '请输入手机号码',
                      inputFormatters: [LengthLimitingTextInputFormatter(11)],
                      keyboardType: TextInputType.phone,
                      onNext: () {
                        checkInput();
                      },
                    ),
              AppTextFormField(
                controller: verifyCodeController,
                leftStr: '验证码',
                leftWidth: 80,
                hintText: '请输入短信验证码',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5) //限制长度
                ],
                suffixIcon: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: SMSCodeView(phoneController.text, SMSType.reset),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return '短信验证码不能为空';
                  } else if (value.length > 6) {
                    return '请输入6位验证码';
                  }
                  return null;
                },
                onNext: () {
                  checkInput();
                },
              ),
              AppTextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                leftStr: '新密码',
                leftWidth: 80,
                hintText: '请输入6-18位新密码',
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: xPasswordFormatter(),
                validator: (value) {
                  return checkPassword();
                },
                onNext: () {
                  checkInput();
                },
              ),
              AppTextFormField(
                controller: confirmPasswordController,
                textInputAction: TextInputAction.next,
                leftStr: '确认密码',
                leftWidth: 80,
                hintText: '请确认新密码',
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: xPasswordFormatter(),
                validator: (value) {
                  return checkPassword();
                },
                onNext: () {
                  checkInput();
                },
              ),
              Spacing.h20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '确认',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ).toBtn(
                40,
                AppPalette.hint,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                colors: [
                  isInput ? Color(0xffA882FF) : Color(0xffdcdcdc),
                  isInput ? Color(0xff645BFF) : Color(0xffdcdcdc)
                ],
                onTap: onResetTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String checkPassword() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    if (password != confirmPassword) {
      return '密码不一致！';
    }
    if (password.length<6 || password.length>18) {
      return '请输入6-18位密码';
    }
    return null;
  }

  onResetTap() {
    if (!isInput) {
      showToast('请先填写完全');
      return;
    }
    // 触摸收起键盘
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    String phone = phoneController.text.trim();
    String code = verifyCodeController.text.trim();
    String password = passwordController.text.trim();
    if (!CommonUtils.checkChinaPhone(phone)) {
      showToast('请输入正确的手机号码！');
      return;
    }

    simpleSub(
        Api.User.resetPassword(
          phone: phone,
          code: code,
          password: password,
        ),
        msg: '重置成功', callback: () async {
      Get.back();
    });
  }
}
