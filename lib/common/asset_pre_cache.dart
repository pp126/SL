import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class AssetPreCache<T> {
  final Set<T> data;

  AssetPreCache(this.data);

  void call() => doPreCache();

  void doPreCache();
}

class SvgPreCache extends AssetPreCache<SvgPicture> {
  SvgPreCache(Set<SvgPicture> data) : super(data);

  SvgPreCache.$(Set<String> data) : super(data.map((it) => SvgPicture.asset(SVG.$(it))).toSet());

  @override
  void doPreCache() async {
    await Future.forEach(data, (it) => precacheImage(it.pictureProvider, Get.context));
  }
}

class ImgPreCache extends AssetPreCache<Image> {
  ImgPreCache(Set<Image> data) : super(data);

  ImgPreCache.x3(Set<String> data) : super(data.map((it) => Image.asset(IMG.$(it))).toSet());

  @override
  void doPreCache() async {
    await Future.forEach(data, (it) => precacheImage(it.image, Get.context));
  }
}
