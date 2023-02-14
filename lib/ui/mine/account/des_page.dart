import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesPage extends StatefulWidget {
  @override
  _DesPageState createState() => _DesPageState();
}

class _DesPageState extends State<DesPage> {
  TextEditingController textController;

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: OAuthCtrl.obj.info['userDesc']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '个性签名',
        action: '提交'.toTxtActionBtn(
          onPressed: () {
            String text = textController.text.trim();
            if (text == null || text.isEmpty) {
              showToast('请填写个性签名');
              return;
            }

            simpleSub(
              OAuthCtrl.obj.updateUserInfo({'userDesc': text}),
              callback: Get.back,
            );
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0))),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                '${textController.text.length}/50',
                style: TextStyle(color: AppPalette.dark, fontSize: 10),
              )),
          Container(
            height: 100,
            child: TextField(
              maxLines: 3,
              minLines: 1,
              controller: textController,
              onChanged: (str) {
                setState(() {});
              },
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              style: TextStyle(color: AppPalette.dark, fontSize: 15),
              decoration: InputDecoration(
                hintText: "请输入新个性签名",
                hintStyle: TextStyle(color: AppPalette.hint, fontSize: 15),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
