import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/room_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_mic_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class RoomUserPage extends StatefulWidget {
  static Future<int> to([ValueChanged<int> callback]) async {
    final result = await Get.to(RoomUserPage());

    if (result is Map) {
      final uid = result['account'];

      callback?.call(uid);

      return uid;
    }

    return null;
  }

  @override
  _RoomUserPageState createState() => _RoomUserPageState();
}

class _RoomUserPageState extends NetPageList<Map, RoomUserPage> {
  final Set<int> micData = RoomMicCtrl.obj.micMap.values.map((e) => e?.user?.uid).toSet();

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('抱Ta上麦'),
      body: super.build(context),
    );
  }

  @override
  Future fetchPage(PageNum page) {
    final roomID = RoomCtrl.obj.roomID;

    return Api.Room.members(roomID, page);
  }

  @override
  List<Map> transform(data) {
    final list = super.transform(data);

    micData;

    return list.where((it) => true).toList(growable: false);
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return InkWell(
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            AvatarView(
              url: item['avatar'],
              size: 48,
              side: BorderSide(width: 2, color: Colors.white),
            ),
            Spacing.w8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['nick'], style: TextStyle(fontSize: 14, color: AppPalette.txtDark)),
                  Spacing.h6,
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () => Get.back(result: item),
    );
  }
}
