import 'package:app/tools.dart';
import 'package:nim_core/nim_core.dart';

abstract class BaseConv<T> {
  final T data;

  BaseConv(this.data);

  NIMSession get conv;

  int get unReadCount => conv.unreadCount ?? 0;

  bool get isBox => false;
}

class ImConv extends BaseConv<NIMSession> {
  ImConv(NIMSession data) : super(data);


  @override
  NIMSession get conv => data;
}

class BoxConv extends BaseConv<List<NIMSession>> {

  @override
   final conv = data.first;

  @override
   final unReadCount = data.length;

  BoxConv(List<NIMSession> data) : super(data);

  @override
  bool get isBox => true;
}

class IConv {
  final String convId;
  final NIMSessionType type;

  IConv({required this.convId, required this.type});

  final onlyViewRx = RxBool(false);

  factory IConv.from(NIMSession data) => IConv(convId: data.sessionId, type: data.sessionType);
}
