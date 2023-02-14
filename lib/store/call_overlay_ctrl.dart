import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/ws_event.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/call/call_bottom_sheet.dart';
import 'package:app/ui/call/call_ctrl.dart';
import 'package:app/ui/call/call_mini_view.dart';
import 'package:app/ui/call/common/hold_help.dart';
import 'package:flutter/material.dart';

enum CallState { Hide, Mini, Back }

class CallOverlayCtrl extends GetxController with BusDisposableMixin {
  final RxBool showRx;

  CallOverlayCtrl(this.showRx);

  final _overlay = _CallOverlay();

  final stateRx = Rx(CallState.Hide);
  final callHold = HoldHelp();

  @override
  void onReady() {
    super.onReady();
    Get.insertOverlay(_overlay);

    ever(showRx, (it) {
      final _state = stateRx.value;

      if (it) {
        if (_state == CallState.Hide) miniState();
      } else {
        if (_state == CallState.Mini) hideState();
      }
    });

    on<CallPushEvent>(
      (event) {
        callHold.lockByAsync(
          Get.showBottomSheet(
            CallBottomSheet(event),
            safeAreaMinimum: AppSize.safeAreaMini,
          ),
        );
      },
      test: (it) {
        return callHold.canRun // 已经弹框，就不在提示
            ? it.type == '直聊' // 直聊需要匹配查找的人为自己
                ? it.data['targetUid'] == OAuthCtrl.obj.uid
                : true
            : false;
      },
    );

    bus(CMD.call_finish, (msg) {
      switch (stateRx.value) {
        case CallState.Back:
          (showRx.value ? miniState : hideState).call();

          CallCtrl.finish(msg);
          break;
        default:
          assert(false);
      }
    });
  }

  @override
  void onClose() {
    Bus.send(CMD.close_overlay, _overlay);

    super.onClose();
  }

  void hideState() => stateRx.value = CallState.Hide;

  void miniState() => stateRx.value = CallState.Mini;

  void backState() => stateRx.value = CallState.Back;

  void to([int targetUid]) async {
    final authCtrl = OAuthCtrl.obj;

    final myUid = authCtrl.uid;
    final isMale = authCtrl.isMale;

    final usedCall = Storage.read<bool>(PrefKey.usedCall(myUid)) ?? false;

    void doNext() {
      final api = Api.Home.sendFlashChat(targetUid);

      simpleSub(
        callHold.unLockByErr(api),
        msg: null,
        whenErr: {500: (e) => Get.alertDialog(e.msg)},
        callback: () async {
          CallCtrl.putByDial(await api);

          if (!usedCall) {
            Storage.write(PrefKey.usedCall(myUid), true);
          }
        },
      );
    }

    if (isMale) {
      if (usedCall) {
        if ((Storage.read<int>(PrefKey.msgCount(myUid)) ?? 0) < 3) {
          Get.alertDialog('与异性用户互动3句，免费体验闪聊互动');

          return;
        }

        if (showTips(PrefKey.tips('闪聊收费提示'))) {
          final tips = '体验闪聊100海星/分钟，是否闪聊心动的Ta~';

          if (await Get.simpleDialog(msg: tips, okLabel: '去体验') != '去体验') {
            return;
          }
        }
      }
    }

    doNext();
  }

  static CallOverlayCtrl get obj => Get.find();
}

class _CallOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<CallOverlayCtrl>(builder: (it) {
      switch (it.stateRx.value) {
        case CallState.Back:
          return CallBackView();
          //todo 去掉闪聊
        // case CallState.Mini:
        //   return CallMiniView();
        default:
          return SizedBox.shrink();
      }
    });
  }
}
