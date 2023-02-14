import 'dart:io';

import 'package:app/3rd/im/im_help.dart';
import 'package:app/3rd/im/im_model.dart';
import 'package:app/event/event.dart';
import 'package:app/tools.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

abstract class _SenderMixin {
  Stream<NIMMessage> sendImage(IConv conv, Either<List<String>, List<XFile>> data) {
    Stream<File> ifPath(List<String> data) {
      return Stream.fromIterable(data).map(((it) => File(it)));
    }

    Stream<File> ifAsset(List<XFile> data) {
      return Stream.fromIterable(data).map((it) => File(it.path));
    }

    Future<NIMMessage> itemBuilder(File file) async {
      final result = await MessageBuilder.createImageMessage(
        filePath: file.path,
        fileSize: file.lengthSync(),
        sessionId: conv.convId,
        sessionType: conv.type,
      );

      return result.data!;
    }

    return data.fold(ifPath, ifAsset).asyncMap(itemBuilder).asyncMap((it) => it.doSend());
  }

  Stream<NIMMessage> sendVideo(IConv conv, Either<List<String>, List<XFile>> data) {
    Stream<File> ifPath(List<String> data) {
      return Stream.fromIterable(data).map(((it) => File(it)));
    }

    Stream<File> ifAsset(List<XFile> data) {
      return Stream.fromIterable(data).map((it) => File(it.path));
    }

    Future<NIMMessage> itemBuilder(File file) async {
      return NIMMessage.videoEmptyMessage(
        filePath: file.path,
        fileSize: file.lengthSync(),
        width: 0,
        height: 0,
        duration: 0,
        displayName: basename(file.path),
        sessionId: conv.convId,
        sessionType: conv.type,
      );
    }

    return data.fold(ifPath, ifAsset).asyncMap(itemBuilder).asyncMap((it) => it.doSend());
  }

  Future<NIMMessage> sendText(IConv conv, String text) async {
    final result = await MessageBuilder.createTextMessage(
      text: text,
      sessionId: conv.convId,
      sessionType: conv.type,
    );

    return await result.data!.doSend();
  }

  Future<NIMMessage> sendExt(IConv conv, IExtData data) async {
    final result = await MessageBuilder.createCustomMessage(
      attachment: NIMCustomMessageAttachment(data: data.toJson()),
      sessionId: conv.convId,
      sessionType: conv.type,
    );

    return await result.data!.doSend();
  }

  Future<NIMMessage> sendVoice(IConv conv, Tuple2<File, Duration> data) async {
    final file = data.value1;

    final result = await MessageBuilder.createAudioMessage(
      filePath: file.path,
      fileSize: file.lengthSync(),
      duration: data.value2.inMilliseconds,
      sessionId: conv.convId,
      sessionType: conv.type,
    );

    return await result.data!.doSend();
  }
}

mixin _MsgMixin on GetxController, GetDisposableMixin {
  @override
  void onInit() {
    super.onInit();

    bindStream(
      IM.chat.onMessage.listen((event) {
        for (final item in event) {
          NewMsgEvent(item).fire();
        }
      }),
    );

    bindStream(
      IM.chat.onMessageStatus.listen((event) {
        MsgStateEvent(event).fire();
      }),
    );

    bindStream(
      IM.chat.onMessageRevoked.listen((event) {
        //
      }),
    );
  }
}

class MessageManagerCtrl extends GetxController with BusGetLifeMixin, GetDisposableMixin, _MsgMixin, _SenderMixin {
  Future<List<NIMMessage>> fetchMsg({
    required IConv conv,
    required int limit,
    NIMMessage? target,
    bool isQueryNew = false,
  }) async {
    try {
      final result = await asyncTrack('searchMessage', action: () {
        if (target == null) {
          return IM.chat.searchMessage(
            conv.type,
            conv.convId,
            MessageSearchOption(
              limit: limit,
              searchContent: '',
              allMessageTypes: true,
              order: isQueryNew ? SearchOrder.ASC : SearchOrder.DESC,
            ),
          );
        } else {
          return IM.chat.queryMessageListEx(
            target,
            isQueryNew ? QueryDirection.QUERY_NEW : QueryDirection.QUERY_OLD,
            limit,
          );
        }
      });

      final data = result.data!;

      xlog('获取本地消息[${conv.convId}] => [${data.length}]条', type: LogType.IM);

      return data;
    } catch (e, s) {
      errLog(e, s: s);

      return [];
    }
    //</editor-fold>
  }
}
