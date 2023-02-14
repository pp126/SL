import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuBottomSheet extends StatefulWidget {
  @override
  _MenuBottomSheetState createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> {
  final isOwner = RoomCtrl.obj.isOwner();

  @override
  Widget build(BuildContext context) {
    final data = [if (isOwner) '关闭房间', '最小化', '退出房间'];

    return GestureDetector(
      onTap: Get.back,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF252142), Color(0xC4252142), Color(0x78252142), Color(0x00252142)],
                stops: [0, 0.5, 0.75, 1],
              ),
            ),
            width: double.infinity,
            height: 290,
            padding: EdgeInsets.only(top: 64),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                for (final it in data)
                  Container(
                    width: 64,
                    height: 64,
                    child: InkResponse(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(SVG.$('room/menu/$it')),
                          Text(
                            it,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      onTap: () => Get.back(result: it),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
