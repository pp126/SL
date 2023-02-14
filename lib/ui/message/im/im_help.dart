import 'package:app/tools.dart';
import 'package:nim_core/nim_core.dart';

import 'conv_manager_ctrl.dart';

export 'package:nim_core/nim_core.dart';

part 'extensions.dart';

class IM {
  IM._();

  static final obj = NimCore.instance;

  static final auth = obj.authService;
  static final chat = obj.messageService;
  static final user = obj.userService;
  static final group = obj.teamService;
  static final system = obj.systemMessageService;
}

class NimHelp {
  NimHelp._();

  static Future<void> markAllMessageRead() async {
    await IM.chat.clearAllSessionUnreadCount();

    Get.find<ConvManagerCtrl>().doRefresh();

    return;
  }
}
