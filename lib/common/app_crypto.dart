import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_des/flutter_des.dart';

class ApiCrypto {
  ApiCrypto._();

  static const _kDesKey = '1ea53d260ecf11e7b56e00163e046a26';

  static Future<String> pwd(String pwd) async {
    return await FlutterDes.encryptToBase64(pwd, _kDesKey);
  }
}

class WsCrypto {
  WsCrypto._();

  static final _iv = IV.fromUtf8('2dba43c93e7884b9');

  static final _decryption = Encrypter(
    AES(
      Key.fromUtf8('09051825305fd819'),
      mode: AESMode.cbc,
    ),
  );

  ///json -> map -> base64 -> aes -> utf8 -> json -> map
  static Map msgDecode(String data) {
    final ed = jsonDecode(data)['ed'];

    return jsonDecode(_decryption.decrypt64(ed, iv: _iv));
  }

  ///map -> json -> utf8 -> aes -> base64 -> map -> json
  static String msgEncode(Map data) {
    final ed = _decryption.encrypt(jsonEncode(data), iv: _iv);

    return jsonEncode({'ed': ed.base64});
  }
}

class UrlCrypto {
  UrlCrypto._();

  static const _kDesKey = 'MIIBIjAN';

  static Future<String> decode(String url) async {
    final base64 = url.replaceAll('\n', '');

    try {
      return await FlutterDes.decryptFromBase64(base64, _kDesKey);
    } on FormatException catch (_) {
      return url;
    } catch (e) {
      return null;
    }
  }
}
