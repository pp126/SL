import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:app/common/app_crypto.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:crypto/crypto.dart';

class ApiHelp {
  ApiHelp._();

  static const _kSignKey = {
    'ios': 'ffe442276e74e2cf5167a2ee83773327',
    'android': '295ca77801888855cae88a1ef68adrf',
  };

  static String sign(Map params, String t) {
    final sb = new StringBuffer();

    final Map mix = SplayTreeMap.of({'t': t}) //
      ..addAll(params);

    mix.forEach((k, v) => sb..write(k)..write('=')..write('$v'));

    sb.write(_kSignKey[params['os']]);

    final input = sb.toString();

    final digest = md5.convert(utf8.encode(input));

    return '$digest'.substring(0, 7);
  }

  static String os() => Platform.operatingSystem;

  static String version() => appInfo.version;

  static String buildNum() => appInfo.buildNumber;

  static String clientID() => 'erban-client';

  static String clientSecret() => 'uyzjdhds';

  static String imei() => Get.find<String>(tag: 'imei');

  static Map<String, dynamic> uidMixin(Map<String, dynamic> args) {
    final ctrl = OAuthCtrl.obj;

    if (ctrl.isLogin) {
      args.putIfAbsent('uid', () => ctrl.uid);
      args.putIfAbsent('ticket', () => ctrl.ticket);
    }

    return args;
  }

  static Future<String> pwd(String pwd) => ApiCrypto.pwd(pwd);
}
