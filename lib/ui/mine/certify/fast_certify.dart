import 'dart:io';

import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/moment/post/post_page.dart';
import 'package:app/widgets/customer/app_textfield.dart';
import 'package:app/widgets/sms_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class FastCertifyPage extends StatefulWidget {
  @override
  _FastCertifyPageState createState() => _FastCertifyPageState();
}

class _FastCertifyPageState extends State<FastCertifyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController(text: '');
  final TextEditingController usernameController = TextEditingController(text: '');
  final TextEditingController idController = TextEditingController(text: '');
  final TextEditingController verifyCodeController = TextEditingController(text: '');
  final phoneFocus = FocusNode(); //焦点控制
  final usernameFocus = FocusNode(); //焦点控制
  final idFocus = FocusNode(); //焦点控制
  final verifyCodeFocus = FocusNode(); //焦点控制
  bool isInput = false;
  VoidCallback listener;

  ImageParamInfo _frontImageInfo = ImageParamInfo(icon: '身份证正面'); //正面图片
  ImageParamInfo _backImageInfo = ImageParamInfo(icon: '身份证背面'); //反面图片
  ImageParamInfo _selfImageInfo = ImageParamInfo(icon: '手持身份证'); //手持图片
  bool isCertify = false;

  ///是否认证
  int auditStatus = 0;

  ///0，审核中；1，审核通过；2，审核拒绝
  String status = '审核中';

  @override
  void initState() {
    super.initState();

    initParams();
    requestForData();
  }

  ///认证情况
  requestForData() {
    return Api.User.getCertifyInfo().then((value) {
      if (value != null && value['auditStatus'] != null) {
        isCertify = true;
        auditStatus = value['auditStatus'];
        usernameController.text = xMapStr(value, 'realName');
        idController.text = xMapStr(value, 'idcardNo');
        phoneController.text = xMapStr(value, 'phone');
        switch (auditStatus) {
          case 0:
            status = '审核中';
            break;
          case 1:
            status = '审核通过';
            break;
          case 2:
            status = '审核拒绝';
            break;
        }
      }
    });
  }

  initParams() async {
    listener = () {
      checkInput();
    };

    usernameController.addListener(listener);
    phoneController.addListener(listener);
    idController.addListener(listener);
    verifyCodeController.addListener(listener);
    checkInput();
  }

  checkInput({FocusNode nextFocus}) {
    isInput = phoneController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        idController.text.isNotEmpty &&
        verifyCodeController.text.isNotEmpty;
    setState(() {});
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus); //聚焦下个输入框
    }
  }

  @override
  void dispose() {
    usernameController.removeListener(listener);
    phoneController.removeListener(listener);
    idController.removeListener(listener);
    verifyCodeController.removeListener(listener);
    usernameController.dispose();
    phoneController.dispose();
    idController.dispose();
    verifyCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 32, 16, 0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppTextFormField(
                  enabled: !isCertify,
                  controller: usernameController,
                  focusNode: usernameFocus,
                  textInputAction: TextInputAction.next,
                  leftStr: '真实姓名',
                  leftWidth: 90,
                  hintText: '请输入您的真实姓名',
                  keyboardType: TextInputType.emailAddress,
                  onNext: () {
                    checkInput(nextFocus: idFocus);
                  },
                ),
                AppTextFormField(
                  enabled: !isCertify,
                  controller: idController,
                  focusNode: idFocus,
                  textInputAction: TextInputAction.next,
                  leftStr: '身份证号码',
                  leftWidth: 90,
                  hintText: '请输入您的身份证号码',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(18) //限制长度
                  ],
                  onNext: () {
                    checkInput(nextFocus: phoneFocus);
                  },
                ),
                AppTextFormField(
                  enabled: !isCertify,
                  controller: phoneController,
                  focusNode: phoneFocus,
                  textInputAction: TextInputAction.next,
                  leftStr: '手机号码',
                  leftWidth: 90,
                  hintText: '请输入手机号码',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11) //限制长度
                  ],
                  validator: (value) {
                    RegExp reg = new RegExp(r'^\d{11}$');
                    if (!reg.hasMatch(value)) {
                      return '请输入11位手机号码';
                    }
                    return null;
                  },
                  onNext: () {
                    checkInput(nextFocus: verifyCodeFocus);
                  },
                ),
                if (!isCertify) ...[
                  AppTextFormField(
                    controller: verifyCodeController,
                    focusNode: verifyCodeFocus,
                    leftStr: '手机验证码',
                    leftWidth: 90,
                    hintText: '请输入短信验证码',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5) //限制长度
                    ],
                    suffixIcon: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: SMSCodeView(phoneController.text, SMSType.IDCertify),
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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      cardWidget('身份证正面', '身份证人像面', _frontImageInfo, () {
                        onImagePickerTap(0);
                      }),
                      cardWidget('身份证背面', '身份证国徽面', _backImageInfo, () {
                        onImagePickerTap(1);
                      }),
                      cardWidget('手持身份证', '手持身份证照片', _selfImageInfo, () {
                        onImagePickerTap(2);
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                  tipItem(),
                  SizedBox(height: 40),
                ],
                btn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  btn() {
    if (!isCertify) {
      return $btn('确认', onCertifyTap);
    } else if (isCertify && status == '审核拒绝') {
      return $btn('重新填写', onCleanTap);
    }
    return $selectBtn();
  }

  $selectBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          status,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ).toTagView(
      40,
      AppPalette.hint,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
      colors: [
        auditStatus == 1 ? Color(0xffA882FF) : Color(0xffdcdcdc),
        isInput ? Color(0xff645BFF) : Color(0xffdcdcdc)
      ],
    );
  }

  $btn(text, onTop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    ).toBtn(
      40,
      AppPalette.hint,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
      colors: [isInput ? Color(0xffA882FF) : Color(0xffdcdcdc), isInput ? Color(0xff645BFF) : Color(0xffdcdcdc)],
      onTap: onTop,
    );
  }

  tipItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              '认证须知',
              style: TextStyle(color: AppPalette.dark, fontSize: 14),
            ),
          ),
          Text(
            """您提供的证件信息将受到严格保护，未经本人许 可不会用于其他途径。身份证绑定后不可修改
您的身份证信息用途仅为身份核实，请放心添加
未成年信息不会通过官方认证
一个身份证/手机号码最多为5个声呐账号作实名验证
目前仅开通中国用户认证，港澳台用户请联系客服处理""",
            style: TextStyle(color: AppPalette.tips, fontSize: 12, height: 2),
          ),
        ],
      ),
    );
  }

  inputBox(String title, String hintText, TextEditingController controller,
      {List<Widget> actions, List<TextInputFormatter> inputFormatters}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          child: Text(
            title,
            style: TextStyle(color: AppPalette.tips, fontSize: 12),
          ),
        ),
        Expanded(
          child: TextField(
            maxLines: 1,
            controller: controller,
            onChanged: (str) {
              setState(() {});
            },
            inputFormatters: inputFormatters ?? [],
            style: TextStyle(color: AppPalette.dark, fontSize: 12, height: 1),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: AppPalette.hint, fontSize: 12),
              border: InputBorder.none,
            ),
          ),
        ),
        ...actions ?? []
      ],
    ).toTagView(60, AppPalette.divider, padding: EdgeInsets.only(left: 20, right: 20));
  }

  Widget cardWidget(String tips, String subTips, ImageParamInfo imageInfo, VoidCallback onPress) {
    double width = (MediaQuery.of(context).size.width - 16 * 5) / 3.0;
    double height = 127;
    return InkWell(
      onTap: onPress,
      child: imageInfo.imagePath != null
          ? Container(
              width: width,
              height: height,
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.file(
                      imageInfo.imagePath,
                      width: width,
                      height: height,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: AppPalette.barrier,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
              width: width,
              height: height,
              decoration: BoxDecoration(
                  color: AppPalette.divider,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  border: Border.all(color: Color(0xffF0F0F0), width: 1)),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Expanded(
                        child: SvgPicture.asset(
                      SVG.$('mine/${imageInfo.icon}'),
                      width: 32,
                      height: 32,
                    )),
                    Text(tips, style: TextStyle(fontSize: 12, color: AppPalette.dark)),
                    Text(subTips, style: TextStyle(fontSize: 10, color: AppPalette.hint)),
                  ],
                ),
              ),
            ),
    );
  }

  onImagePickerTap(int type) async {
    DialogUtils.showPictureDialog(context, callBack: (image) {
      uploadImage(image, type);
    });
  }

  uploadImage(PickedFile image, int type) {
    simpleSub(() {
      FileApi.upLoadFile(image, 'certify/').then((value) {
        if (value != null) {
          var file = File(image.path);
          setState(() {
            switch (type) {
              case 0:
                {
                  _frontImageInfo.imagePath = file;
                  _frontImageInfo.url = value;
                }
                break;
              case 1:
                {
                  _backImageInfo.imagePath = file;
                  _backImageInfo.url = value;
                }
                break;
              case 2:
                {
                  _selfImageInfo.imagePath = file;
                  _selfImageInfo.url = value;
                }
                break;
            }
          });
        }
      });
    }, msg: null);
  }

  onCleanTap() {
    usernameController.text = '';
    phoneController.text = '';
    idController.text = '';
    verifyCodeController.text = '';
    // 触摸收起键盘
    FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      isCertify = false;
    });
  }

  onCertifyTap() {
    if (!isInput) {
      showToast('请先填写完全');
      return;
    }
    // 触摸收起键盘
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    String userName = usernameController.text.trim();
    String phone = phoneController.text.trim();
    String id = idController.text.trim();
    String code = verifyCodeController.text.trim();

    simpleSub(
        Api.User.certify(
          realName: userName,
          phone: phone,
          idcardNo: id,
          smsCode: code,
          idcardFront: _frontImageInfo.url,
          idcardHandheld: _selfImageInfo.url,
          idcardOpposite: _backImageInfo.url,
        ),
        msg: '提交认证信息成功，请等待审核', callback: () {
      Navigator.pop(context);
    });
  }
}
