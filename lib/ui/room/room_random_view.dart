import 'package:app/tools.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomRandomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = $RoomView();

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ObxValue<Rx<Offset>>(
            (pos) => Transform.translate(
              offset: pos.value,
              child: Draggable(
                child: child,
                feedback: child,
                childWhenDragging: SizedBox.shrink(),
                onDragEnd: (it) => pos.value = it.offset,
              ),
            ),
            Offset(Get.width - 56, Get.height / 2).obs,
          ),
        ),
      ],
    );
  }

  Widget $RoomView() {
    return Material(
      elevation: 4,
      color: Colors.white,
      type: MaterialType.circle,
      child: GestureDetector(
        onTap: () {
          RoomPage.to(-1);
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: SvgPicture.asset(SVG.$('room/随机进入房间'), width: 46, height: 46),
        ),
      ),
    );
  }
}
