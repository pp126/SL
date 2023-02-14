import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class InputPage extends StatelessWidget {
  final String title;
  final TextInputType keyboardType;
  final TextEditingController _ctrl;
  final int maxLines;

  InputPage({this.title = '请输入', String initial, this.keyboardType, this.maxLines})
      : _ctrl = TextEditingController(text: initial);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        title,
        action: '保存'.toTxtActionBtn(onPressed: () => Get.back(result: _ctrl.text)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: TextField(
          controller: _ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}
