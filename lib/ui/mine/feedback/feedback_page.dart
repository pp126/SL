import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedBackPage extends StatefulWidget {
  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  TextEditingController textController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '意见反馈',
        action: '提交'.toTxtActionBtn(
          onPressed: () {
            String text = textController.text.trim();
            String phone = phoneController.text.trim();
            if (text == null || text.isEmpty || phone == null || phone.isEmpty) {
              showToast('请填写完整信息');
              return;
            }
            if (!CommonUtils.checkChinaPhone(phone)) {
              showToast('请输入正确的手机号码！');
              return;
            }
            simpleSub(Api.User.commitFeedback(text, phone), callback: Get.back);
          },
        ),
      ),
      backgroundColor: AppPalette.background,
      body: Column(
        children: [
          inputBox(),
          phoneBox(),
        ],
      ),
    );
  }

  inputBox() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                '${textController.text.length}/200',
                style: TextStyle(color: AppPalette.dark, fontSize: 10),
              )),
          Container(
            height: 150,
            child: TextField(
              maxLines: 6,
              minLines: 2,
              controller: textController,
              onChanged: (str) {
                setState(() {});
              },
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              style: TextStyle(color: AppPalette.dark, fontSize: 15),
              decoration: InputDecoration(
                hintText: "请详细描述您所遇到的问题与情况，感谢你提出宝贵的意见！",
                hintStyle: TextStyle(color: AppPalette.hint, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  phoneBox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('联系方式', style: TextStyle(color: AppPalette.tips, fontSize: 15)),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: TextField(
            maxLines: 1,
            controller: phoneController,
            onChanged: (str) => true,
            inputFormatters: [LengthLimitingTextInputFormatter(11)],
            style: TextStyle(color: AppPalette.dark, fontSize: 14),
            decoration: InputDecoration(
              hintText: "请输入您联系方式",
              hintStyle: TextStyle(color: AppPalette.hint, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ).toTagView(61, Colors.white,
      radius: 12,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      padding: EdgeInsets.symmetric(horizontal: 16,),
    );
  }
}
