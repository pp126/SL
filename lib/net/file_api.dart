import 'dart:convert';
import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slugid/slugid.dart';
import 'package:tuple/tuple.dart';

typedef String GenKey(String path, String saveDir);

class FileApi {
  FileApi._();

  static final config = _Config();
  static final _hmacSha1 = Hmac(sha1, utf8.encode(config.secretKey));

  static Dio get _dio {
    final $5s = Duration(seconds: 5).inMilliseconds;
    final $30s = Duration(seconds: 30).inMilliseconds;

    final dio = Dio(
      BaseOptions(
        sendTimeout: $30s,
        connectTimeout: $5s,
        receiveTimeout: $5s,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return dio;
  }

  static String _sign(String txt) {
    final data = utf8.encode(txt);

    return base64UrlEncode(_hmacSha1.convert(data).bytes);
  }

  static Future<String> upLoadFile(PickedFile file, String saveDir,
      {GenKey genKey = _genKey}) async {
    final img = await file.readAsBytes();

    final key = _genKey(file.path, saveDir);

    final form = {
      'key': key,
      'token': _token(_putPolicy(key)),
      'file': MultipartFile.fromBytes(img, filename: key),
    };

    final Tuple2<Response, String> data = Tuple2.fromList(
      await Future.wait(
        [
          _dio.post(config.putUrl, data: FormData.fromMap(form)),
          compute<Uint8List, String>(_blurHash, img),
        ],
        eagerError: true,
      ),
    );

    final _path = data.item1.data['key'];
    final fragment = Uri.encodeComponent(data.item2);

    return '${Uri(scheme: 'http', host: config.imgHost.first, path: _path, fragment: fragment)}';
  }

  static Future<String> upLoadAudioFile(PickedFile file, String saveDir,
      {GenKey genKey = _genKey}) async {
    final img = await file.readAsBytes();

    final key = _genKey(file.path, saveDir);

    final form = {
      'key': key,
      'token': _token(_putPolicy(key)),
      'file': MultipartFile.fromBytes(img, filename: key),
    };
    Response response =
        await _dio.post(config.putUrl, data: FormData.fromMap(form));
    var data = response.data;
    final _path = data['key'];
    print('response = ${response.data}');
    return '${Uri(scheme: 'http', host: config.imgHost.first, path: _path,)}';
  }

  static String _blurHash(Uint8List data) {
    final img = copyResize(decodeImage(data), width: 42, height: 42);

    final hash = BlurHash.encode(img).hash;

    return hash;
  }

  static String _putPolicy(String key) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final data = {
      'deadline': now ~/ 1000 + (5 * 60),
      'scope': '${config.bucket}:$key',
    };

    return base64UrlEncode(utf8.encode(jsonEncode(data)));
  }

  static String _token(String putPolicy) =>
      '${config.accessKey}:${_sign(putPolicy)}:$putPolicy';

  static String _genKey(String _, String saveDir) => '$saveDir${Slugid.nice()}';
}

class _Config {
  final imgHost = {'img.yanwz8.cn', 'img.yanwz8.cn'};
  // final imgHost = {'img.shengna.tv', 'img.ligaozhong.com'};
  final String putUrl = 'https://upload-z2.qiniup.com';

  final String accessKey = '457vkFDnKzk3enjtT3dv2MFB4QSyeO0TFjFtlDSP';
  final String secretKey = 'T7SE_8KdCG2VAvrxA_WKENlXOPrDV1zzmOTJU38u';

  final String bucket = 'xiy';
}
