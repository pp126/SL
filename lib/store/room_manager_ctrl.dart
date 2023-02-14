import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';

import 'async_ctrl.dart';

class RoomManagerCtrl extends AsyncCtrl<Set<int>> with BusDisposableMixin {
  final int roomID;

  RoomManagerCtrl(this.roomID) : super({});

  @override
  Future get api => Api.Room.roomManagers(roomID, PageNum(size: 999));

  @override
  Set<int> transform(data) {
    final set = (data as List).map<int>((it) => it['account']).toSet();

    return set;
  }

  @override
  void onInit() {
    super.onInit();
    int _account(WsEvent event) => event.data['member']['account'];

    bool _test(WsEvent event) => event.data['room_id'] == '$roomID';

    //<editor-fold desc="管理员变动">
    on<ChatRoomManagerAdd>((event) => value.add(_account(event)), test: _test);
    on<ChatRoomManagerRemove>((event) => value.remove(_account(event)), test: _test);
    //</editor-fold>
  }

  bool isAdmin(int uid) => value.contains(uid);

  static RoomManagerCtrl get obj => Get.find();
}
