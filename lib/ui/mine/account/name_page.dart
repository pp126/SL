import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NamePage extends StatefulWidget {
  bool isReturn;

  NamePage({this.isReturn: false});

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: OAuthCtrl.obj.info['nick'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '修改昵称',
        action: '提交'.toTxtActionBtn(
          onPressed: () {
            String text = textController.text.trim();
            if (text == null || text.isEmpty) {
              showToast('请填写完整信息');
              return;
            }

            if (widget.isReturn) {
              Get.back(result: text);
            } else {
              simpleSub(
                OAuthCtrl.obj.updateUserInfo({'nick': text}),
                callback: Get.back,
              );
            }
          },
        ),
      ),
      backgroundColor: AppPalette.background,
      body: Column(
        children: [
          inputBox(),
        ],
      ),
    );
  }

  inputBox() {
    return Container(
      decoration: new BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextField(
        maxLines: 1,
        controller: textController,
        onChanged: (str) {
          setState(() {});
        },
        inputFormatters: [LengthLimitingTextInputFormatter(200)],
        style: TextStyle(color: AppPalette.dark, fontSize: 15),
        decoration: InputDecoration(
          hintText: "请输入新昵称",
          hintStyle: TextStyle(color: AppPalette.hint, fontSize: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
