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

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isBind = false;
  bool isInput = false;
  VoidCallback listener;

  final TextEditingController phoneController = TextEditingController(text: '');
  final TextEditingController oldPasswordController = TextEditingController(text: '');
  final TextEditingController passwordController = TextEditingController(text: '');
  final TextEditingController confirmPasswordController = TextEditingController(text: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initParams();
  }
  initParams() async {
    listener = () {
      checkInput();
    };

    phoneController.addListener(listener);
    oldPasswordController.addListener(listener);
    passwordController.addListener(listener);
    confirmPasswordController.addListener(listener);
  }

  checkInput() {
    setState(() {
      isInput = phoneController.text.isNotEmpty
          && oldPasswordController.text.isNotEmpty
          && passwordController.text.isNotEmpty
          && confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    phoneController.removeListener(listener);
    oldPasswordController.removeListener(listener);
    passwordController.removeListener(listener);
    confirmPasswordController.removeListener(listener);
    phoneController.dispose();
    oldPasswordController.dispose();
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
      appBar: xAppBar('????????????'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              isBind?Container(
                margin: EdgeInsets.only(bottom: 20,top: 10),
                alignment: Alignment.centerLeft,
                child: Text('???????????? : $phone',style: TextStyle(fontSize: 12,color: AppPalette.tips),),
              ):AppTextFormField(
                controller: phoneController,
                textInputAction: TextInputAction.next,
                leftStr: '?????????',
                leftWidth: 80,
                hintText: '?????????????????????',
                inputFormatters: [LengthLimitingTextInputFormatter(11)],
                keyboardType: TextInputType.phone,
                onNext: (){
                  checkInput();
                },
              ),
              AppTextFormField(
                controller: oldPasswordController,
                textInputAction: TextInputAction.next,
                leftStr: '?????????',
                leftWidth: 80,
                hintText: '??????????????????',
                obscureText:true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [LengthLimitingTextInputFormatter(18)],
                validator: (value){
                  return checkPassword();
                },
                onNext: (){
                  checkInput();
                },
              ),
              AppTextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                leftStr: '?????????',
                leftWidth: 80,
                hintText: '?????????6-18????????????',
                obscureText:true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: xPasswordFormatter(),
                validator: (value){
                  return checkPassword();
                },
                onNext: (){
                  checkInput();
                },
              ),
              AppTextFormField(
                controller: confirmPasswordController,
                textInputAction: TextInputAction.next,
                leftStr: '????????????',
                leftWidth: 80,
                hintText: '??????????????????',
                obscureText:true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: xPasswordFormatter(),
                validator: (value){
                  return checkPassword();
                },
                onNext: (){
                  checkInput();
                },
              ),
              Spacing.h20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '??????',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ).toBtn(
                40,
                AppPalette.hint,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                colors: [isInput?Color(0xffA882FF):Color(0xffdcdcdc), isInput?Color(0xff645BFF):Color(0xffdcdcdc)],
                onTap: onResetTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
  String checkPassword(){
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    if(password != confirmPassword){
      return '??????????????????';
    }
    if (password.length<6 || password.length>18) {
      return '?????????6-18?????????';
    }
    return null;
  }
  onResetTap(){
    if(!isInput){
      showToast('??????????????????');
      return;
    }
    // ??????????????????
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    String phone = phoneController.text.trim();
    String old = oldPasswordController.text.trim();
    String password = passwordController.text.trim();
    if (!CommonUtils.checkChinaPhone(phone)) {
      showToast('?????????????????????????????????');
      return;
    }

    simpleSub(
        Api.User.changePassword(
          phone: phone,
          oldPassword: old,
          newPassword: password,
        ),
        msg: '????????????',
        callback: () async {
          Get.back();
        }
    );
  }
}
