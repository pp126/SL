import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

typedef Future OnSubmitted(String txt);

class MsgBottomSheet extends StatefulWidget {
  final TextEditingController ctrl;
  final OnSubmitted onSub;

  MsgBottomSheet(this.ctrl, this.onSub);

  @override
  _MsgBottomSheetState createState() => _MsgBottomSheetState();
}

class _MsgBottomSheetState extends State<MsgBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: MsgInputView(ctrl: widget.ctrl, onSub: widget.onSub),
    );
  }
}

class MsgInputView extends StatelessWidget {
  final TextEditingController ctrl;
  final OnSubmitted onSub;

  MsgInputView({this.ctrl, this.onSub});

  @override
  Widget build(BuildContext context) {
    final dec = InputDecoration(
      hintText: '说点什么吧。',
      hintStyle: TextStyle(fontSize: 14, color: Colors.black12),
      isDense: true,
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: ShapeDecoration(
              color: AppPalette.divider,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(2), left: Radius.circular(20)),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: ctrl,
              decoration: dec,
              autofocus: true,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ),
        Spacing.w6,
        Material(
          color: AppPalette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: Container(
              width: 77,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                '发送',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            onTap: () async {
              final txt = ctrl.text.trim();

              if (txt.isNotEmpty) {
                ctrl.clear();

                Get.back();

                onSub(txt);
              }
            },
          ),
        ),
      ],
    );
  }
}
