import 'dart:html';

import 'package:app/net/api.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/call/call_try_bottom_sheet.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ChatCtrl extends GetxController {
  final String title;
  final String avatar;
  final int imUid;
  final Map imUser;

  ChatCtrl(this.title, this.avatar, this.imUid) : imUser = {'avatar': avatar, 'uid': imUid};

  bool _needPaid;

  final _flagRx = RxInt(0);
  final _countRx = RxInt(0);
  final inputRx = RxBool(true);

  final authCtrl = OAuthCtrl.obj;

  @override
  void onInit() async {
    super.onInit();
    NimHelp.startChat('$imUid');

    if (authCtrl.isMale) {
      _needPaid = true;

      final wallet = Get.find<WalletCtrl>();

      final walletWorker = ever(wallet.value, (Map data) {
        if (data['goldNum'] < 10) {
          inputRx.value = _flagRx.value != 0;
        }
      });

      final _tmp = Expando<VoidCallback>();

      ever(_flagRx, (int it) {
        switch (it) {
          case -1:
            walletWorker();

            _needPaid = false;
            inputRx.value = true;

            break;
          case 0:
            inputRx.value = wallet.value['goldNum'] >= 10;

            final fun = _tmp[this];

            if (fun != null) {
              fun();
              _tmp[this] = null;
            }

            break;
          case 1:
            _tmp[this] = () async {
              final tips = '免费互动次数已使用，每次与Ta互动需消耗10海星哟';

              Get.rechargeDialog(tips);
            };

            break;
        }
      });
    } else {
      _needPaid = false;
    }

    if (_needPaid) {
      final data = await Api.Home.getUserIsPrivateChat();

      _flagRx.value = data['flag'];

      if (_flagRx.value == -1 && data['isPopup'] == false) {
        Get.alertDialog('恭喜你账号已消耗了10000海星 ，\n已解锁免费私聊功能');

        Api.Home.savePopup();
      }
    }

    _initMsgCount();
  }

  void _initMsgCount() {
    final uid = authCtrl.uid;

    _countRx.value = Storage.read<int>(PrefKey.msgCount(uid)) ?? 0;

    ever(
      _countRx,
      (it) {
        Storage.write(PrefKey.msgCount(uid), it);

        if (authCtrl.isMale && it == 3) {
          CallTryBottomSheet.to();
        }
      },
    );
  }

  @override
  void onClose() {
    NimHelp.closeChat();

    super.onClose();
  }

  void sendText(String txt) {
    NimHelp.sendText(txt);

    _paid(txt);
  }

  void sendImage(PickedFile file) {
    NimHelp.sendImage(file);

    _paid('[图片]');
  }

  void sendRecording() => _paid('[语音]');

  _paid(String content) {
    _countRx.value++;

    if (_needPaid) {
      simpleTry(() async {
        final result = await Api.Home.privateChat(content: content, targetUid: imUid);

        Bus.send(CMD.gold_change, -(result['gold']));

        _flagRx.value = result['flag'];
      }, whenErr: {
        2103: (e) async {
          final tips = '账号海星数不足，请及时充值海星，避免错过Ta的温柔哟～';

          Get.rechargeDialog(tips);
        },
      });
    }
  }
}
