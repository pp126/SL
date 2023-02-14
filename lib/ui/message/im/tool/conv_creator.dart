import 'dart:async';

import 'package:app/tools.dart';

import '../conv_manager_ctrl.dart';
import '../im_help.dart';
import '../model/conv.dart';

abstract class ConvCreator {
  final convManager = Get.find<ConvManagerCtrl>();

  FutureOr<IConv> create();
}

class SingleChatConvCreator extends ConvCreator {
  final int uid;

  SingleChatConvCreator(this.uid);

  @override
  IConv create() => IConv(convId: '$uid', type: NIMSessionType.p2p);
}
