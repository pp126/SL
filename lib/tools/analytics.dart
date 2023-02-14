import 'dart:async';

import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flurry/flurry.dart';

class Analytics {
  Analytics._();

  static Future<Null> subEvent(String name, [Map<String, String> properties]) async {
    return await Flurry.logEvent(name);
  }
}

void analyticsInit() {
  Flurry.initialize(androidKey: '3WPDCFPFCCCY32BPDJWJ', iosKey: 'FG2NJ8GS8N73VTB47VQ5');

  Bus.sub(CMD.login, (_) => Flurry.setUserId('${OAuthCtrl.obj.uid}'));

  Api.User.decActivation();
}
