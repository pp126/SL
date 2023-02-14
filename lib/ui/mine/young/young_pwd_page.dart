import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/screen.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YoungPwdPage extends StatefulWidget {
  final bool isOpen;
  YoungPwdPage({this.isOpen});
  @override
  _YoungPwdPageState createState() => _YoungPwdPageState();
}

class _YoungPwdPageState extends State<YoungPwdPage> {
  TextEditingController pwd = TextEditingController();
  TextEditingController verifyPwd = TextEditingController();

  bool isInputPwd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('${widget.isOpen ? '关闭' : '开启'}青少年模式'),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height - Screen.topBarHeight),
          child: Column(
            children: [
              SizedBox(height: 48),
              Text(isInputPwd ? '确认密码' : '输入密码',
                  style: TextStyle(color: AppPalette.dark, fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 75),
                child: Text('启动时间锁，需要先设置独立密码独立密码适用于时间锁，青少年模式', style: TextStyle(color: AppPalette.tips, fontSize: 15)),
              ),
              getPwdInput().toTagView(61, AppPalette.divider, margin: EdgeInsets.symmetric(horizontal: 64, vertical: 40)),
              Spacer(),
              Text(isInputPwd ? '确认' : '下一步', style: TextStyle(color: Colors.white, fontSize: 12))
                  .toBtn(40, AppPalette.primary, margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40), onTap: () {
                if (isInputPwd) {
                  String password = verifyPwd.text.trim();
                  if (password.isEmpty) {
                    showToast('请输入密码');
                    return;
                  }
                  onSetTap();
                } else {
                  String password = pwd.text.trim();
                  if (password.isEmpty) {
                    showToast('请输入密码');
                    return;
                  }
                  isInputPwd = true;
                  setState(() {});
                }
              }),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPwdInput() {
    TextStyle inputTs = TextStyle(fontSize: 15, color: AppPalette.dark, height: 1);
    TextStyle hintStyle = TextStyle(fontSize: 15, color: AppPalette.hint);
    return isInputPwd
        ? TextField(
            textAlign: TextAlign.center,
            controller: verifyPwd,
            maxLines: 1,
            onChanged: (str) {
              setState(() {});
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]")), //只允许输入小数
              LengthLimitingTextInputFormatter(6)
            ],
            style: inputTs,
            decoration: InputDecoration(
              hintText: "确认密码",
              hintStyle: hintStyle,
              border: InputBorder.none,
            ),
            obscureText: true,
          )
        : TextField(
            textAlign: TextAlign.center,
            controller: pwd,
            maxLines: 1,
            onChanged: (str) {
              setState(() {});
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]")), //只允许输入小数
              LengthLimitingTextInputFormatter(6)
            ],
            style: inputTs,
            decoration: InputDecoration(
              hintText: "请输入6位数字密码",
              hintStyle: hintStyle,
              border: InputBorder.none,
            ),
            obscureText: true,
          );
  }
  errorPassword(String message){
    showToast(message);
    setState(() {
      isInputPwd = false;
    });
  }
  onSetTap() async {
    String password = pwd.text.trim();
    String verifyPassword = verifyPwd.text.trim();
    if (password != verifyPassword) {
      errorPassword('密码前后不一致');
      return;
    }

    if (widget.isOpen) {
      bool value = await Api.User.checkCipherCode(
        password,
      );
      if (!value) {
        errorPassword('密码错误');
        return;
      }
      simpleSub(Api.User.closeTeensMode(), callback: () {
        Get.back();
      }, msg: '关闭成功');
    }else{
      simpleSub(Api.User.saveTeensMode(
        password,
      ), callback: () {
        Get.back();
      }, msg: '开启成功');
    }
  }
}
