import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app/common/theme.dart';
import 'package:app/net/host.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/moment_action_tap.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:app/widgets/customer/app_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DialogUtils {
  static showAlertDialog(BuildContext context, String title, String text) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  text ?? '',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FloatingActionButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ///弹出评论操作框
  static showChooseDialog(BuildContext context, {Size size, var vector3, bool isNormal, var momentData}) {
    var child = MonentActionItem(
      size: size,
      vector3: vector3,
      isNormal: isNormal,
      momentData: momentData,
    );
    return isNormal
        ? showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return child;
            })
        : showDialog(
            barrierColor: isNormal ? AppPalette.barrier : AppPalette.transparent,
            context: context,
            builder: (BuildContext context) {
              return child;
            },
          );
  }

  ///弹出图片选择框
  static showPictureDialog(BuildContext context, {ValueChanged callBack}) {
    var data = ['拍照', '相册'];
    return showCupertinoPopup(
      context,
      data: data,
      onItemClickListener: (index, value) async {
        Get.back();

        imagePicker(callBack, source: index == 0 ? ImageSource.camera : ImageSource.gallery);
      },
    );
  }

  ///弹出选择框
  static showCupertinoPopup(BuildContext context, {List data, OnItemClickListener onItemClickListener}) {
    return showCupertinoModalPopup(
      context: context,
//      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),///毛玻璃的效果
      builder: (BuildContext context) {
        return CommonBottomSheet(
          list: data,
          onItemClickListener: onItemClickListener,
        );
      },
    );
  }

  ///弹出性别选择框
  static showSexDialog(BuildContext context, {ValueChanged<int> callBack}) {
    var data = ['男', '女'];
    return showCupertinoPopup(
      context,
      data: data,
      onItemClickListener: (index, value) async {
        switch (value) {
          case '男':
            if (callBack != null) callBack(1);
            break;
          case '女':
            if (callBack != null) callBack(2);
            break;
        }
        Get.back();
      },
    );
  }

  ///弹出选项
  static showBottomSheet(BuildContext context, Widget page, {bool checkLogin = false}) {
    if (checkLogin) {
      ///检查登录，未登录先跳登录
      ///to do
      return;
    }

    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        barrierColor: AppPalette.barrier,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
        builder: (BuildContext context) {
          return page;
        });
  }

  static Future<Null> showCustomerOptionDialog(BuildContext context,
      {String title,
      String message,
      String cancel,
      String option,
      bool barrierDismissible = false,
      TextStyle titleStyle,
      TextStyle contextStyle,
      TextStyle cancelStyle,
      TextStyle optionStyle,
      VoidCallback cancelCallback,
      VoidCallback optionCallback}) {
    titleStyle = titleStyle ?? TextStyle(fontSize: 13, color: AppPalette.primary);
    contextStyle = contextStyle ?? TextStyle(fontSize: 13, color: AppPalette.primary);
    cancelStyle = cancelStyle ?? TextStyle(fontSize: 13, color: Color(0xFFDBDBDB));
    optionStyle = optionStyle ?? TextStyle(fontSize: 13, color: AppPalette.primary);

    cancel = cancel ?? '取消';
    option = option ?? '确定';
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return Theme(
              data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.transparent),
              child: Dialog(
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            title == null
                                ? SizedBox()
                                : Container(
                                    height: 48.0,
                                    child: DefaultTextStyle(style: titleStyle, child: Center(child: Text(title))),
                                  ),
                            message == null
                                ? SizedBox()
                                : DefaultTextStyle(
                                    style: contextStyle,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                          child: Text(
                                        message,
                                        textAlign: TextAlign.center,
                                      )),
                                    )),
                            Container(
                              height: 48.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  cancel.isEmpty
                                      ? SizedBox()
                                      : Expanded(
                                          child: InkWell(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(16.0),
                                                bottomRight:
                                                    cancel.isEmpty ? Radius.circular(16.0) : Radius.circular(0.0)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              cancelCallback?.call();
                                            },
                                            child: Container(
                                              height: 48,
                                              child: Center(
                                                child: DefaultTextStyle(
                                                    style: cancelStyle,
                                                    child: Semantics(
                                                      child: Text(cancel),
                                                      namesRoute: true,
                                                      onTap: cancelCallback,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ),
                                  option.isEmpty
                                      ? SizedBox()
                                      : Expanded(
                                          child: InkWell(
                                            borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(16.0),
                                                bottomLeft:
                                                    cancel.isEmpty ? Radius.circular(16.0) : Radius.circular(0.0)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              optionCallback?.call();
                                            },
                                            child: Container(
                                              height: 48,
                                              child: Center(
                                                child: DefaultTextStyle(
                                                    style: optionStyle,
                                                    child: Semantics(
                                                      child: Text(option),
                                                      namesRoute: true,
                                                      onTap: optionCallback,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  static showAgreementDialog(RxBool rx) async {
    if (Storage.read<bool>(PrefKey.AgreementConfirm) == true) {
      rx.value = true;

      return;
    }

    rx.value = false;

    final txt = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '请你务必谨慎阅读、充分理解"服务协议"和"隐私政策"各条款，'
                '包括但不限于：为了向你提供即时通讯、内容分享等服务，我们需要你的设备信息'
                '、操作日志等个人信息。你可以在"设置"中查看、更变、删除个人信息并管理你的'
                '授权。\n你可阅读',
          ),
          TextSpan(
            text: '《用户协议》',
            style: TextStyle(color: AppPalette.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.to(
                    AppWebPage(
                      title: '用户协议',
                      url: 'http://${host.host}/agreement/user.html',
                    ),
                    popGesture: true,
                    preventDuplicates: false,
                  ),
          ),
          TextSpan(text: '和'),
          TextSpan(
            text: '《隐私协议》',
            style: TextStyle(color: AppPalette.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.to(
                    AppWebPage(
                      title: '隐私协议',
                      url: 'http://${host.host}/agreement/userPrivacy.html',
                    ),
                    popGesture: true,
                    preventDuplicates: false,
                  ),
          ),
          TextSpan(text: '了解详细信息。如你同意，请点击"同意"开始接受我们的服务。'),
        ],
      ),
      style: TextStyle(fontSize: 12, color: AppPalette.dark),
    );

    final _dialog = AlertDialog(
      title: Text('服务协议与隐私政策'),
      content: SingleChildScrollView(
        child: txt,
      ),
      actions: <Widget>[
        FloatingActionButton(
          child: Text('暂不使用', style: TextStyle(color: AppPalette.dark)),
          onPressed: () => exit(0),
        ),
        FloatingActionButton(
          child: Text('同意'),
          onPressed: () => Get.back(result: '同意'),
        ),
      ],
    );

    final result = await showDialog(
      context: Get.context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => _dialog,
    );

    if (result == '同意') {
      rx.value = true;

      Storage.write(PrefKey.AgreementConfirm, true);
    }
  }
}
