import 'dart:async';

import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/timer_mixin.dart';

class OnlineCtrl extends GetxController with TimerDisposableMixin {
  @override
  void onInit() {
    super.onInit();

    addTimer(
      Timer(5.seconds, () {
        _getIntegral();

        addTimer(Timer.periodic(5.minutes, _getIntegral));
      }),
    );
  }

  void _getIntegral([_]) {
    if (OAuthCtrl.obj.isLogin) Api.Family.getIntegral();
  }
}
