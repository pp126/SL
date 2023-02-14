import 'dart:ui' as ui;

import 'package:app/common/cache_manager.dart';
import 'package:app/net/api.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RdAvatarCtrl extends AsyncCtrl<List> {
  final _tmp = <Future<ui.Image>>[];
  final _manager = ImgCacheManager.obj;

  @override
  Future get api => Api.Home.getRandomAvatar();

  @override
  String get persistent => PrefKey.RdAvatar;

  @override
  set value(List data) {
    super.value = data;

    take5;
  }

  List<Future<ui.Image>> get take5 {
    final out = List<Future<ui.Image>>.of(_tmp, growable: false);

    _tmp
      ..clear()
      ..addAll(_take5);

    return out;
  }

  Iterable<Future<ui.Image>> get _take5 {
    value.shuffle();

    return value.take(5).map((it) async {
      final img = await _getImg(it, _Draw.size);

      final recorder = ui.PictureRecorder();

      _Draw.drawImage(ui.Canvas(recorder), img);

      return recorder.endRecording().toImage(_Draw.size, _Draw.size);
    });
  }

  Future<ui.Image> _getImg(String url, int size) async {
    final bytes = await _manager //
        .getSingleFile(url)
        .then((it) => it.readAsBytes());

    final image = await ui
        .instantiateImageCodec(bytes, targetHeight: size, targetWidth: size)
        .then((it) => it.getNextFrame())
        .then((it) => it.image);

    return image;
  }
}

class _Draw {
  static const size = 150;

  static const _radius = size / 2;
  static const _circle = Offset(_radius, _radius);

  static final _rRect = RRect.fromRectAndRadius(
    Rect.fromLTRB(0, 0, size.toDouble(), size.toDouble()),
    Radius.circular(_radius),
  );

  static final _paint = //
      ui.Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..color = Color(0x80F1EEFF)
        ..strokeWidth = 8;

  static void drawImage(ui.Canvas canvas, ui.Image image) {
    canvas
      ..clipRRect(_rRect)
      ..drawImage(image, ui.Offset.zero, _paint)
      ..drawCircle(_circle, _radius, _paint);
  }
}
