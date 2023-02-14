import 'package:app/store/room_sticker_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/view_state.dart';
import 'package:flutter/material.dart';

class MicStickersBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.width * 0.618,
      child: RoomStickerCtrl.use(builder: (data) {
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.618,
          ),
          itemCount: data.length,
          itemBuilder: (_, i) => createItem(data[i]),
        );
      }),
    );
  }

  Widget createItem(StickersInfo item) {
    return InkWell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GiftImgState(
              child: NetImage(item.path, optimization: false),
            ),
          ),
          Container(
            height: 24,
            alignment: Alignment.center,
            child: Text(item.name, style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
      onTap: () => Get.back(result: item),
    );
  }
}
