import 'package:app/event/room_event.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';

class RoomLikeCtrl extends GetxController {
  final int _roomID;

  RoomLikeCtrl(this._roomID);

  var isLike = false;

  Future<void> like(bool isAdd) async {
    isLike = isAdd;
    update();

    await Api.Room.like(_roomID, isAdd);

    showToast(isAdd ? '关注成功' : '取消关注成功');

    Bus.fire(RoomInEvent());
  }

  @override
  void onInit() async {
    super.onInit();

    isLike = await Api.Room.isLike(_roomID);

    update();
  }
}
