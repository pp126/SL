import 'dart:async';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:flutter/material.dart';

enum SMSType {
  register,///用户注册
  login,///登录
  reset,///重置密码
  IDCertify,///用户身份验证
  bindPhone,///绑定手机号
}

class SMSCodeView extends StatefulWidget {
  String mobile;
  String tips;
  SMSType type;

  SMSCodeView(
      this.mobile,
      this.type,
      {this.tips,}
      );

  @override
  _SMSCodeViewState createState() => _SMSCodeViewState();
}

class _SMSCodeViewState extends State<SMSCodeView> {
  Timer timer;
  int count = 60;
  bool isEnable = true;

  @override
  void dispose() {

    timer?.cancel();
    timer = null;

    super.dispose();
  }
  ///发送短信验证码
  sendSMS(){
    if(widget.mobile==null || widget.mobile.isEmpty){
      showToast(widget.tips??'请输入手机号！');
      return;
    }
    if (!CommonUtils.checkChinaPhone(widget.mobile)) {
      showToast('请输入正确的手机号码！');
      return;
    }
    switch(widget.type){
      case SMSType.register:
        {
          simpleSub(Api.OAuth.registerSms(widget.mobile), callback: () {
            setState(() {
              isEnable = false;
              setTimer();
            });
            showToast('已发送');
          });
        }
        break;
      case SMSType.login:
        {
          simpleSub(Api.OAuth.registerSms(widget.mobile,type: 2), callback: () {
            setState(() {
              isEnable = false;
              setTimer();
            });
            showToast('已发送');
          });
        }
        break;
      case SMSType.reset:
        {
          simpleSub(Api.OAuth.registerSms(widget.mobile,type: 3), callback: () {
            setState(() {
              isEnable = false;
              setTimer();
            });
            showToast('已发送');
          });
        }
        break;
      case SMSType.IDCertify:
        {
          simpleSub(Api.OAuth.certifySms(widget.mobile), callback: () {
            setState(() {
              isEnable = false;
              setTimer();
            });
            showToast('已发送');
          });
        }
        break;
      case SMSType.bindPhone:
        {
          simpleSub(Api.User.bindPhoneSMS(phone: widget.mobile), callback: () {
            setState(() {
              isEnable = false;
              setTimer();
            });
            showToast('已发送');
          });
        }
        break;
    }
  }
  /*
  * 设置定时器
  * */
  setTimer() {
    count = 60;
    timer = Timer.periodic(Duration(seconds: 1), (res) {
      setState(() {
        if(count>0) {
          count--;
        }else{
          closeTimer();
          isEnable = true;
        }
      });
    });

  }
  /*
  * 设置定时器
  * */
  closeTimer() {
    timer?.cancel();
    timer = null;
  }
  @override
  Widget build(BuildContext context) {
    return Text(
      isEnable?'获取验证码':'重新发送($count)',
      style: TextStyle(
        fontSize:12 ,
        color: Colors.white,
      ),
    ).toBtn(32,isEnable?AppPalette.primary:AppPalette.hint,onTap: isEnable?(){
      sendSMS();
    }:null);
  }
}
