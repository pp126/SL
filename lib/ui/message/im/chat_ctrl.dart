import 'dart:io';

import 'package:app/3rd/im/im_help.dart';
import 'package:app/3rd/im/im_model.dart';
import 'package:app/event/event.dart';
import 'package:app/exception.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/message/input/ext/export.dart';
import 'package:app/ui/message/input/ext/input_action_red_envelope.dart';
import 'package:app/ui/message/input/input_ctrl.dart';
import 'package:app/ui/message/input/input_view.dart';
import 'package:app/ui/red_envelope/chat_red_envelope_page.dart';
import 'package:app/ui/room/gift_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ready_ctrl_mixin.dart';
import 'message_manager_ctrl.dart';
import 'tool/chat_scroll_mixin.dart';
import 'tool/conv_creator.dart';

mixin GetConvMixin {
  abstract final Either<NIMSession, ConvCreator> _conv;

  late final IConv conv;

  @mustCallSuper
  Future<void> _initConv() async {
    conv = await verifyConv(
      await _conv.fold((l) => IConv.from(l), (r) => r.create()),
    );
  }

  FutureOr<IConv> verifyConv(final IConv conv) => conv;
}

mixin GroupMixin on GetConvMixin {
  late final String groupId;

  @override
  Future<void> _initConv() async {
    await super._initConv();

    groupId = conv.convId;
  }
}

abstract class ChatCtrl extends GetxController
    with
        GetConvMixin,
        AutoScrollMixin,
        EndScrollMixin,
        BusGetLifeMixin,
        ReadyMixin,
        ReadyCtrlMixin,
        GetDisposableMixin,
        GetSingleTickerProviderStateMixin {
  final kPageSize = 20;

  final msgManager = Get.find<MessageManagerCtrl>();
  final backgroundRx = RxnString();
  final isMuteRx = false.obs;

  final oldMsgRx = RxList<NIMMessage>();
  final newMsgRx = RxList<NIMMessage>();

  final selectRx = Rxn<Set<String>>();

  final fullRx = Rx(true);

  List<NIMMessage> get msgList => CombinedListView([oldMsgRx, newMsgRx]);

  abstract final InputConfig inputConfig;

  @override
  void onInit() {
    super.onInit();

    _init();
  }

  @override
  void onClose() {
    isReady.then(
      (_) {
        final data = [
          NIMSessionInfo(sessionId: conv.convId, sessionType: conv.type),
        ];

        return IM.chat.clearSessionUnreadCount(data);
      },
    );

    super.onClose();
  }

  @override
  Future<bool> onEndScroll() async {
    final target = oldMsgRx.firstOrNull ?? newMsgRx.firstOrNull;

    final result = //
        await msgManager
            .fetchMsg(conv: conv, target: target, limit: kPageSize)
            .minTime(const Duration(milliseconds: 618));

    if (target != null) {
      final index = result.indexWhere((it) => it.messageId == target.messageId);

      if (index == -1) {
        addOldMsg(result);
      } else {
        addOldMsg(result.take(index)); //去重
      }
    } else {
      addOldMsg(result);
    }

    return result.length >= kPageSize;
  }

  @override
  Future<bool> onTopScroll() async {
    final target = newMsgRx.lastOrNull ?? oldMsgRx.lastOrNull;

    final result = //
        await msgManager
            .fetchMsg(conv: conv, target: target, limit: kPageSize, isQueryNew: true)
            .minTime(const Duration(milliseconds: 618));

    if (target != null) {
      final index = result.indexWhere((it) => it.messageId == target.messageId);

      if (index == -1) {
        addNewMsg(result);
      } else {
        addNewMsg(result.skip(index + 1)); //去重
      }
    } else {
      addNewMsg(result);
    }

    return result.length >= kPageSize;
  }

  @mustCallSuper
  Future<void> _init() async {
    try {
      await _initConv();

      if (isClosed) return;

      _initMsg();

      if (isClosed) return;

      markReady();
    } catch (e, s) {
      markFail(e, s);

      rethrow;
    }
  }

  Future<void> _initMsg() async {
    bindWorker(
      ever<bool>(keyboardRx, (b) {
        if (b) animeToEnd();
      }),
    );

    on<NewMsgEvent>(
      (event) async {
        final msg = event.msg;

        if (!isClosed) {
          final items = addNewMsg(msg);

          if (items != null && (autoRx.isTrue || msg.isOutgoingMsg)) animeToEnd();
        }
      },
      test: (it) => it.msg.sessionId == conv.convId,
    );

    on<MsgStateEvent>(
      (event) {
        final id = event.msg.messageId;

        [newMsgRx, oldMsgRx].any((data) {
          for (var i = 0; i < data.length; ++i) {
            final item = data[i];

            if (id == item.messageId) {
              data
                ..[i] = event.msg
                ..refresh();

              return true;
            }
          }

          return false;
        });
      },
      test: (it) => it.msg.sessionId == conv.convId,
    );

    final result = await msgManager.fetchMsg(conv: conv, limit: kPageSize);

    if (result.length < kPageSize) {
      xlog('初始化数据不足一页', type: LogType.IM);

      setFetchFlag(fetchTop: false, fetchBottom: false);
    }

    addNewMsg(result);
  }

  Iterable<NIMMessage>? addNewMsg(data) {
    if (data is NIMMessage) {
      if (_msgFilter(data)) {
        newMsgRx.add(data);

        return [data];
      }
    } else if (data is Iterable<NIMMessage>) {
      final _data = data.where(_msgFilter);

      newMsgRx.addAll(_data);

      return _data;
    } else {
      assert(false, data);
    }

    return null;
  }

  void addOldMsg(Iterable<NIMMessage> data) {
    oldMsgRx.insertAll(0, data.where(_msgFilter));
  }

  void assignMsgData(Iterable<NIMMessage> data) {
    newMsgRx
      ..clear()
      ..refresh();

    oldMsgRx
      ..assignAll(data.where(_msgFilter))
      ..refresh();
  }

  bool _msgFilter(NIMMessage data) {
    switch (data.messageType) {
      case NIMMessageType.text:
      case NIMMessageType.image:
      case NIMMessageType.audio:
      case NIMMessageType.video:
      case NIMMessageType.location:
      case NIMMessageType.file:
      case NIMMessageType.avchat:
      case NIMMessageType.notification:
      case NIMMessageType.tip:
      case NIMMessageType.custom:
        return true;
      case NIMMessageType.netcall:
      case NIMMessageType.robot:
      case NIMMessageType.undef:
      case NIMMessageType.appCustom:
      case NIMMessageType.qiyuCustom:
        return false;
    }
  }
}

class ChatMsgSender extends MsgSender
    with TxtSender, VoiceSender, ImageSender, VideoSender, CallSender, GiftSender, RedEnvelopeSender {
  final IConv _conv;
  final VoidCallback _toEnd;
  final ValueChanged _msgAdd;
  final MessageManagerCtrl _msgManager;

  ChatMsgSender(ChatCtrl target)
      : _conv = target.conv,
        _toEnd = target.animeToEnd,
        _msgAdd = target.addNewMsg,
        _msgManager = target.msgManager;

  void $AddMsg(task) async {
    assert(task is Future<NIMMessage> || task is Stream<NIMMessage>, '数据错误 => [$task]');

    try {
      dynamic msgOut;

      if (task is Future<NIMMessage>) {
        msgOut = await task;
      } else if (task is Stream<NIMMessage>) {
        msgOut = await task.toList();
      }

      if (msgOut != null) {
        _msgAdd(msgOut);

        _toEnd();
      }
    } on LogicException catch (e) {
      showToast(e.msg);
    } catch (e, s) {
      errLog(e, s: s);
    }
  }

  @override
  void callVoice() {
    assert(_conv.type == NIMSessionType.p2p);

    final uid = int.parse(_conv.convId);

    CallOverlayCtrl.obj.to(uid);
  }

  @override
  void sendImage(List<XFile> data) {
    $AddMsg(
      _msgManager.sendImage(_conv, Right(data)),
    );
  }

  @override
  void sendVideo(List<XFile> data) {
    $AddMsg(
      _msgManager.sendVideo(_conv, Right(data)),
    );
  }

  @override
  void sendTxt(String data) {
    $AddMsg(
      _msgManager.sendText(_conv, data),
    );
  }

  @override
  void sendVoice(Tuple2<File, Duration> data) {
    $AddMsg(
      _msgManager.sendVoice(_conv, data),
    );
  }

  @override
  void sendGift() async {
    assert(_conv.type == NIMSessionType.p2p);

    final uid = _conv.convId;

    final user = await IM.user.getUserInfo(uid).then((val) => val.data);

    GiftBottomSheet.to(
      GiftSend2UserCtrl(uid: int.parse(uid), avatar: user?.avatar),
    );
  }

  @override
  void sendRedEnvelope() {
    assert(_conv.type == NIMSessionType.p2p);

    final uid = _conv.convId;

    Get.to(() => ChatRedEnvelopePage(int.parse(uid)));
  }
}

class SingleChatCtrl extends ChatCtrl {
  @override
  final Either<NIMSession, ConvCreator> _conv;

  SingleChatCtrl(this._conv);

  @override
  late final InputConfig inputConfig = InputConfig.userChat(
    InputCtrl(ChatMsgSender(this), hint: '请文明发言以防被禁言～'.i18n),
  );
}

extension<T> on Future<T> {
  Future<T> minTime(Duration dur) {
    return Future.wait([this, Future.delayed(dur)]).then((it) => it[0]);
  }
}
