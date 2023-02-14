import 'package:app/net/ws_event.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';

class RoomSelfGiftCtrl extends GetxController with BusDisposableMixin {
  final value = RxList(<Map>[]);

  @override
  void onInit() async {
    super.onInit();

    final myUid = OAuthCtrl.obj.uid;

    on<OneGiftEvent>((event) {
      final data = event.data;

      if (data['targetUid'] == myUid) value.add(data);
    });
    on<MultipleGiftEvent>((event) {
      final data = event.data;

      if (data['targetUids'].contains(myUid)) value.add(data);
    });
  }

  void clear() => value.clear();

  static RoomSelfGiftCtrl get obj => Get.find();
}
