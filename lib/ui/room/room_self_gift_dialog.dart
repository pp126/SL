import 'package:app/common/theme.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_self_gift_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/society/water/water_list.dart';
import 'package:flutter/material.dart';

class RoomSelfGiftDialog extends GetWidget<RoomSelfGiftCtrl> {
  static to() {
    Get.showBottomSheet(RoomSelfGiftDialog(), bgColor: AppPalette.sheetDark);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 458,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: WaterList({}.obs, RoomCtrl.obj.roomUid, '${RoomCtrl.obj.value['title']}的礼物'),
        ),
      ),
    );
  }

  Widget $ListView(List<Map> data) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: data.length,
      itemBuilder: (_, i) => createItem(data[i]),
      separatorBuilder: (_, __) => Divider(),
    );
  }

  Widget createItem(Map data) {
    return Container(
      height: 52,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '收取 '),
                  TextSpan(
                    text: '${data['nick']}',
                    style: TextStyle(color: AppPalette.tips),
                  ),
                  TextSpan(text: ' ${data['giftName']}'),
                ],
              ),
              style: TextStyle(color: AppPalette.txtDark),
            ),
            Text(
              '+${data['useGiftPurseGold']}珍珠',
              style: TextStyle(color: AppPalette.primary, fontWeight: fw$SemiBold),
            )
          ],
        ),
      ),
    );
  }
}
