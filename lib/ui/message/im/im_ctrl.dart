import 'dart:io';

import 'package:app/3rd/im/im_help.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/foundation.dart';

import '../ready_ctrl_mixin.dart';

const _appKey = 'c53276b504122c16c5aae958a9970d46';

class ImCtrl extends GetxService with ReadyMixin, ReadyCtrlMixin, BusGetLifeMixin {
  @override
  void onReady() async {
    try {
      await _initClient();

      markReady();
    } catch (e, s) {
      markFail(e, s);
    }
  }

  Future _initClient() async {
    final _handler = FlutterError.onError;

    try {
      await IM.obj.initialize(
        Platform.isIOS //
            ? NIMIOSSDKOptions(
                appKey: _appKey,
                // autoLoginInfo: token?.auth,
                enableAsyncLoadRecentSession: true,
              )
            : NIMAndroidSDKOptions(
                appKey: _appKey,
                // autoLoginInfo: token?.auth,
                shouldSyncStickTopSessionInfos: true,
              ),
      );
    } catch (e, s) {
      errLog(e, s: s, type: LogType.IM);
    } finally {
      FlutterError.onError = _handler;
    }
  }
}

class ImAuth extends GetxController with ReadyMixin, ReadyCtrlMixin, GetDisposableMixin {
  final NIMLoginInfo auth;

  ImAuth(AuthInfo auth) : auth = NIMLoginInfo(account: '${auth.uid}', token: auth.imToken);

  @override
  void onReady() {
    _doLogin();
  }

  @override
  void onClose() {
    _doLogout();

    super.onClose();
  }

  Future<void> _doLogin() async {
    if (isClosed) return;

    await Get.find<ImCtrl>().isReady;

    try {
      final isOK = await _signIn();

      markReady();
    } catch (e, s) {
      markFail(e, s);
    }
  }

  Future<void> _doLogout() async {
    try {
      await _signOut();
    } catch (e, s) {
      errLog(e, s: s, type: LogType.IM);
    }
  }

  Future<bool> _signIn() {
    return IM.auth.login(auth).then((val) => val.isSuccess).timeout(const Duration(minutes: 1));
  }

  Future<void> _signOut() {
    return IM.auth.logout().timeout(const Duration(seconds: 2));
  }
}
