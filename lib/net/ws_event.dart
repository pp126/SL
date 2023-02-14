import 'dart:convert';

import 'package:app/store/room_ctrl.dart';
import 'package:app/tools/log.dart';

class FirstCMD {
  static const RichMsg = 1000;
  static const ClearMsg = 2000;
  static const Tips = 3000;
  static const RoomSet = 8;
  static const OneGift = 3;
  static const MultipleGift = 12;
}

abstract class WsEvent {
  final Map data;

  WsEvent(this.data);

  String get name;

  factory WsEvent.fromMsg(Map msg) {
    final route = msg['route'];
    final reqData = msg['req_data'];

    xlog('ROUTE[$route]', name: 'WS');

    switch (route) {
      case 'sendMessageReport':
        final tmp = reqData['custom'];
        final custom = tmp is Map ? tmp : jsonDecode(tmp);

        final cmd1 = custom['first'];
        final cmd2 = custom['second'];
        final data = custom['data'];

        switch (cmd1) {
          case FirstCMD.OneGift:
            return OneGiftEvent(data);
          case FirstCMD.MultipleGift:
            return MultipleGiftEvent(data);
          case 16:
            switch (cmd2) {
              case 16:
                return HideEvent('平台广播');
            }

            break;
          case 33:
            switch (cmd2) {
              case 1:
                return UpdateCharmEvent(data);
            }

            break;
          case FirstCMD.RoomSet:
            switch (cmd2) {
              case 81:
                return UpMicEvent(data);
              case 82:
                return DownMicEvent(data);
            }

            return RoomSettingMsgEvent(data, cmd2);
          case FirstCMD.RichMsg:
            switch (cmd2) {
              case 1:
                return StickersMsgEvent(data);
              case 2:
                return StickersGameMsgEvent(data);
            }

            break;
          case FirstCMD.ClearMsg:
            switch (cmd2) {
              case 1:
                return ClearMsgEvent(data);
            }

            break;
          case FirstCMD.Tips:
            switch (cmd2) {
              case 1:
                return TipsMsgEvent(data);
            }

            break;
        }

        break;
      case 'chatRoomMemberIn':
        return ChatRoomMemberIn(reqData);
      case 'chatRoomMemberExit':
        return ChatRoomMemberExit(reqData);
      case 'sendTextReport':
        return SendTextReport(reqData);
      case 'QueueMemberUpdateNotice':
        return QueueMemberUpdateNotice(reqData);
      case 'QueueMicUpdateNotice':
        return QueueMicUpdateNotice(reqData);
      case 'ChatRoomInfoUpdated':
        return ChatRoomInfoUpdated(reqData);
      case 'ChatRoomMemberKicked':
        return ChatRoomMemberKicked(reqData);
      case 'ChatRoomManagerAdd':
        return ChatRoomManagerAdd(reqData);
      case 'ChatRoomManagerRemove':
        return ChatRoomManagerRemove(reqData);
    }

    return null;
  }

  @override
  String toString() {
    return 'WsEvent{name: $name, data: $data}';
  }
}

abstract class _SendMessageReport extends WsEvent {
  final RoomSettingCmd cmd;

  _SendMessageReport(Map data, int second)
      : cmd = RoomSettingCmd(second),
        super(data);
}

class HideEvent extends WsEvent {
  final String info;

  HideEvent(this.info) : super(null);

  @override
  String get name => '忽略消息 -> $info';
}

class OneGiftEvent extends WsEvent {
  OneGiftEvent(Map data) : super(data);

  @override
  String get name => '单个礼物';
}

class MultipleGiftEvent extends WsEvent {
  MultipleGiftEvent(Map data) : super(data);

  @override
  String get name => '全麦礼物';
}

class DownMicEvent extends WsEvent {
  DownMicEvent(Map data) : super(data);

  @override
  String get name => '抱Ta下麦';
}

class UpMicEvent extends WsEvent {
  UpMicEvent(Map data) : super(data);

  @override
  String get name => '抱Ta上麦';
}

class RoomDrawEvent extends WsEvent {
  RoomDrawEvent(Map data) : super(data);

  @override
  String get name => '全服礼物广播';
}

class BigGiftEvent extends WsEvent {
  BigGiftEvent(Map data) : super(data);

  @override
  String get name => '大礼物广播';
}

class PublicChatEvent extends WsEvent {
  PublicChatEvent(Map data) : super(data);

  @override
  String get name => '公聊信息';
}

class RoomHornEvent extends WsEvent {
  RoomHornEvent(Map data) : super(data);

  @override
  String get name => '使用喇叭';
}

class RoomSettingMsgEvent extends _SendMessageReport {
  RoomSettingMsgEvent(Map data, int second) : super(data, second);

  @override
  String get name => '房间设置';
}

class ChatRoomMemberIn extends WsEvent {
  ChatRoomMemberIn(Map data) : super(data);

  @override
  String get name => '用户加入房间';
}

class ChatRoomMemberExit extends WsEvent {
  ChatRoomMemberExit(Map data) : super(data);

  @override
  String get name => '用户离开房间';
}

class SendTextReport extends WsEvent {
  SendTextReport(Map data) : super(data);

  @override
  String get name => '消息反馈';
}

class StickersMsgEvent extends WsEvent {
  StickersMsgEvent(Map data) : super(data);

  @override
  String get name => '贴纸';
}

class StickersGameMsgEvent extends WsEvent {
  StickersGameMsgEvent(Map data) : super(data);

  @override
  String get name => '贴纸游戏';
}

class QueueMemberUpdateNotice extends WsEvent {
  QueueMemberUpdateNotice(Map data) : super(data);

  @override
  String get name => '用户上下麦';
}

class QueueMicUpdateNotice extends WsEvent {
  QueueMicUpdateNotice(Map data) : super(data);

  @override
  String get name => '更新麦位状态信息';
}

class ChatRoomInfoUpdated extends WsEvent {
  ChatRoomInfoUpdated(Map data) : super(data);

  @override
  String get name => '房间信息更新';
}

class UpdateCharmEvent extends WsEvent {
  final Map<int, Map> charm;

  UpdateCharmEvent(Map data)
      : charm = data['latestCharm'].map<int, Map>((k, v) => MapEntry(k is int ? k : int.parse(k), v as Map)),
        super(data);

  @override
  String get name => '更新魅力';
}

class ChatRoomMemberKicked extends WsEvent {
  ChatRoomMemberKicked(Map data) : super(data);

  @override
  String get name => '房间踢人';
}

class ChatRoomManagerAdd extends WsEvent {
  ChatRoomManagerAdd(Map data) : super(data);

  @override
  String get name => '房间添加管理员';
}

class ChatRoomManagerRemove extends WsEvent {
  ChatRoomManagerRemove(Map data) : super(data);

  @override
  String get name => '房间删除管理员';
}

class ClearMsgEvent extends WsEvent {
  ClearMsgEvent(Map data) : super(data);

  @override
  String get name => '清空公屏';
}

class TipsMsgEvent extends WsEvent {
  TipsMsgEvent(Map data) : super(data);

  @override
  String get name => '提醒消息';
}

class CallPushEvent extends WsEvent {
  final String type;

  CallPushEvent(this.type, Map data) : super(data);

  @override
  String get name => '闪聊请求[$type]';
}
