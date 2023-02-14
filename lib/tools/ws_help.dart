import 'dart:async';

import 'package:app/net/host.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';

class WxHelp {
  WxHelp._();

  static void init() async {
    registerWxApi(appId: 'wx0c88d757ac4a762e', universalLink: 'https://${host.host}/weixin/');
  }

  static Future<bool> openMiniProgram(String userName, {String path}) async {
    final result = await launchWeChatMiniProgram(username: userName, path: path);

    return result;
  }
}
