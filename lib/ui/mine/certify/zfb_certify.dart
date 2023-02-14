import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/post/post_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ZFBCertifyPage extends StatefulWidget {
  @override
  _ZFBCertifyPageState createState() => _ZFBCertifyPageState();
}

class _ZFBCertifyPageState extends State<ZFBCertifyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController(text: '');
  final TextEditingController idController = TextEditingController(text: '');
  final usernameFocus = FocusNode(); //焦点控制
  final idFocus = FocusNode(); //焦点控制
  final verifyCodeFocus = FocusNode(); //焦点控制

  bool isInput = false;
  VoidCallback listener;

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
    }, onError: (e) {
      print(e);
    });
  }

  initParams() async {
    listener = () {
      checkInput();
    };

    usernameController.addListener(listener);
    idController.addListener(listener);
    checkInput();
  }

  checkInput({FocusNode nextFocus}) {
    isInput = usernameController.text.isNotEmpty && idController.text.isNotEmpty;
    setState(() {});
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus); //聚焦下个输入框
    }
  }

  @override
  void dispose() {
    usernameController.removeListener(listener);
    idController.removeListener(listener);
    usernameController.dispose();
    idController.dispose();
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
                    ]),
                if (!isCertify) tipItem(),
                Spacing.h32,
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

  onCleanTap() {
    usernameController.text = '';
    idController.text = '';
    // 触摸收起键盘
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      isCertify = false;
    });
  }

  onCertifyTap() async {
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
    String id = idController.text.trim();

    await simpleSub(() async {
      final url = await Api.User.aliCertify(id, userName);
      if (url != null && url != '') {
        await launch(url);
        Get.back();
      }
    }, msg: null);
  }
}
