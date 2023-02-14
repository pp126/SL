import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';

class ChatTipsView extends StatelessWidget {
  final RxBool showRx;
  final String tips;

  ChatTipsView(this.showRx, this.tips);

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(fontSize: 12, color: Color(0xFFB8ACFF));

    return Container(
      height: 32,
      decoration: ShapeDecoration(
        color: AppPalette.txtWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 12),
              alignment: Alignment.center,
              child: Text(tips, style: ts),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: InkResponse(
              child: Icon(Icons.close, size: 12, color: Color(0xFFB8ACFF)),
              onTap: () {
                showRx.value = false;

                Storage.write(PrefKey.chatTips(tips), true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
