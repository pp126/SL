import 'package:app/common/theme.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';

class RoomHornView extends StatefulWidget {
  @override
  _RoomHornViewState createState() => _RoomHornViewState();
}

class _RoomHornViewState extends State<RoomHornView> with BusStateMixin {
  final rxMsg = '快向各位宣告你的到来，和大家交个朋友吧！'.obs;

  @override
  void initState() {
    super.initState();

    on<RoomHornEvent>((event) => rxMsg.value = event.data['msg']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: ShapeDecoration(
        color: AppPalette.txtWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(
            '头条',
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.primary,
              fontWeight: fw$SemiBold,
            ),
          ),
          Spacing.w12,
          Expanded(
              // todo 这里需要处理
              // child: ObxValue<RxString>(
              //   (it) => MarqueeText(
              //     it.value,
              //     style: TextStyle(fontSize: 14, color: Color(0xFFB8ACFF)),
              //     gap: 18,
              //   ),
              //   rxMsg,
              // ),
              ),
        ],
      ),
    );
  }
}
