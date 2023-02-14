part of 'im_help.dart';

extension XSession on NIMSession {
  bool isSystemContent() {
    final type = lastMessageType;

    if (type == null || type != NIMMessageType.custom) {
      return false;
    } else {
      final data = lastMessageAttachment.<NIMCustomMessageAttachment>()?.data;

      return data?['first'] == 10 && data?['second'] == 101;
    }
  }

  bool get filter {
    //TODO 不知道干什么的
    const block = {
      '36',
      '346',
    };

    return block.contains(sessionId);
  }

  String get summary {
    return _toSummary(type: lastMessageType, content: lastMessageContent, attach: lastMessageAttachment);
  }
}

extension XMessage on NIMMessage {
  String get summary {
    return _toSummary(type: messageType, content: content, attach: messageAttachment);
  }

  bool get isOutgoingMsg {
    return messageDirection == NIMMessageDirection.outgoing;
  }

  NIMMessageStatus get deliveryState {
    return status!;
  }

  Future<NIMMessage> doSend() async {
    final result = await IM.chat.sendMessage(message: this);

    assert(result.isSuccess, result.errorDetails);

    return result.data!;
  }
}

String _toSummary({ NIMMessageType type, String content, NIMMessageAttachment attach}) {
  // ignore: missing_enum_constant_in_switch
  switch (type) {
    case NIMMessageType.text:
      return content!;
    case NIMMessageType.image:
      return '[图片消息]';
    case NIMMessageType.audio:
      return '[语音消息]';
    case NIMMessageType.video:
      return '[视频消息]';
    case NIMMessageType.location:
      return '[位置信息]';
    case NIMMessageType.notification:
      return '[通知]';
    case NIMMessageType.file:
      return '[文件]';
    case NIMMessageType.tip:
      return '[提醒]';
    case NIMMessageType.robot:
      return '[机器人]';
    case NIMMessageType.custom:
      try {
        final data = attach.typeIf<NIMCustomMessageAttachment>()?.data;

        switch (data?['first']) {
          case 10:
            return data!['data'];
          default:
            final title = data?['title'];

            if (title != null) {
              return '[$title]';
            }
        }
      } catch (e) {
        // ignore
      }
      break;
    default:
      return '[其它]';
  }

  return '';
}
