import 'dart:async';

import 'package:app/common/app_crypto.dart';
import 'package:app/common/cache_manager.dart';
import 'package:app/tools.dart';
import 'package:quiver/cache.dart';
import 'package:rxdart/rxdart.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class GiftEffectCtrl extends GetxService {
  static final _cache1 = MapCache<String, MovieEntity>.lru(maximumSize: 3);

  final _ctrl = PublishSubject<String>();

  Stream<MovieEntity> get stream => _ctrl.asyncMap(_map);

  Future<void> play(String url) async {
    if (!url.isNullOrBlank) {
      url = await UrlCrypto.decode(url);

      GiftCacheManager.obj.getSingleFile(url);

      _ctrl.add(url);
    }
  }

  @override
  void onClose() async => await _ctrl.close();

  static Future<MovieEntity> _map(String url) async {
    final parser = SVGAParser.shared;

    xlog(url, name: 'GiftEffect');

    return _cache1.get(url, ifAbsent: (it) async {
      xlog('ifAbsent => $it', name: 'GiftEffect');

      final file = await GiftCacheManager.obj.getSingleFile(it);

      xlog('CacheFile => $file', name: 'GiftEffect');

      final result = await parser.decodeFromBuffer(await file.readAsBytes());

      xlog('ParserFile => ${result.bitmapCache}', name: 'GiftEffect');

      return result;
    });
  }

  static GiftEffectCtrl get obj => Get.find();
}
