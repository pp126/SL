import 'package:app/store/room_ctrl.dart';
import 'package:app/store/room_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:flutter/material.dart';

class RoomMiniView extends StatelessWidget {
  final RoomOverlayCtrl ctrl;

  RoomMiniView(this.ctrl);

  final _isDrag = false.obs;

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
                data: 0,
                child: child,
                feedback: child,
                childWhenDragging: SizedBox.shrink(),
                onDragStarted: () => _isDrag.value = true,
                onDragEnd: (it) {
                  _isDrag.value = false;

                  pos.value = it.offset;
                },
              ),
            ),
            Offset(Get.width - 56, Get.height / 2).obs,
          ),
        ),
        Obx(() {
          return _isDrag.value
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 100 + Get.mediaQuery.padding.bottom,
                  child: DragTarget(
                    onAccept: (int _) async => await ctrl.closeState(),
                    builder: (_, __, ___) {
                      return Container(
                        color: Colors.red.withOpacity(0.96),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: Colors.white),
                            DefaultTextStyle(
                              style: TextStyle(fontSize: 18, color: Colors.white),
                              child: Text('退出房间'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : SizedBox();
        }),
      ],
    );
  }

  Widget $RoomView() {
    return GetX<RoomCtrl>(
      builder: (it) {
        final data = it.value;

        return Material(
          elevation: 4,
          color: Colors.white,
          type: MaterialType.circle,
          child: GestureDetector(
            onTap: RoomPage.show,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: AvatarView(url: data['avatar'], size: 46),
            ),
          ),
        );
      },
    );
  }
}
