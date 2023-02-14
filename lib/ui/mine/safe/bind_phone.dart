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

class BindPhonePage extends StatefulWidget {
  @override
  _BindPhonePageState createState() => _BindPhonePageState();
}

class _BindPhonePageState extends State<BindPhonePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isBind = false;
  bool isInput = false;
  VoidCallback listener;

  final TextEditingController phoneController = TextEditingController(text: '');
  final TextEditingController verifyCodeController = TextEditingController(text: '');

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
    verifyCodeController.addListener(listener);
  }

  checkInput() {
    setState(() {
      isInput = phoneController.text.isNotEmpty && verifyCodeController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    phoneController.removeListener(listener);
    verifyCodeController.removeListener(listener);
    phoneController.dispose();
    verifyCodeController.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('换绑手机号'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: OAuthCtrl.use(builder: (user) {
          String phone = xMapStr(user, 'phone',);
          phone = xPhoneStr(phone);
          isBind = phone.isNotEmpty;
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20,top: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(isBind?'当前绑定手机号 : $phone':'尚未绑定手机号',style: TextStyle(fontSize: 12,color: AppPalette.tips),),
                ),
                AppTextFormField(
                  controller: phoneController,
                  textInputAction: TextInputAction.next,
                  leftStr: '换绑手机号',
                  leftWidth: 90,
                  hintText: '请输入要换绑的手机号',
                  inputFormatters: [LengthLimitingTextInputFormatter(11)],
                  keyboardType: TextInputType.phone,
                  onNext: (){
                    checkInput();
                  },
                ),
                AppTextFormField(
                  controller: verifyCodeController,
                  leftStr: '手机验证码',
                  leftWidth: 90,
                  hintText: '请输入短信验证码',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5)//限制长度
                  ],
                  suffixIcon: Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: SMSCodeView(
                        phoneController.text,SMSType.bindPhone),
                  ),
                  validator: (value){
                    if (value.isEmpty) {
                      return '短信验证码不能为空';
                    }else if(value.length > 6){
                      return '请输入6位验证码';
                    }
                    return null;
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
                      '确认',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ).toBtn(
                  40,
                  AppPalette.hint,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                  colors: [isInput?Color(0xffA882FF):Color(0xffdcdcdc), isInput?Color(0xff645BFF):Color(0xffdcdcdc)],
                  onTap: onBindTap,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  onBindTap(){
    if(!isInput){
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

    if (!CommonUtils.checkChinaPhone(phone)) {
      showToast('请输入正确的手机号码！');
      return;
    }

    simpleSub(
        Api.User.bindPhone(
          phone: phone,
          code: code,
        ),
        msg: '绑定成功',
        callback: () async {
          await OAuthCtrl.obj.updateUserInfo({'phone': phone});
          Navigator.pop(context);
        }
    );
  }
}
