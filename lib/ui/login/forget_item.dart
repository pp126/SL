import 'package:app/common/theme.dart';
import 'package:app/ui/mine/safe/forget_page.dart';
import 'package:flutter/material.dart';
import 'package:app/tools.dart';

class ForgetItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('忘记密码',
      style: TextStyle(fontSize: 14,color: AppPalette.primary),
    ).toBtn(30, Colors.transparent,
        margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
        width: 100,
        onTap: (){
          Get.to(ForgetPasswordPage());
        });
  }
}