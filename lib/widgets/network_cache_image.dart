import 'dart:ui';

import 'package:app/common/cache_manager.dart';
import 'package:app/net/file_api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:tuple/tuple.dart';

final _pixelRatio = window.devicePixelRatio;

class NetImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;
  final BlendMode colorBlendMode;
  final AlignmentGeometry alignment;
  final bool optimization;

  const NetImage(
    this.url, {
    Key key,
    this.fit,
    this.width,
    this.height,
    this.alignment,
    this.color,
    this.colorBlendMode,
    this.optimization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uri uri;

    try {
      uri = Uri.parse(url);
    } catch (e, s) {
      return _errorView(context, e, s);
    }

    if (uri == null || uri.host.isNullOrBlank) return _errorView(context, null, null);

    return optimization == false
        ? _imgView(uri, provider0(uri))
        : LayoutBuilder(
            builder: (_, size) {
              final img = provider(uri, w: width ?? size.maxWidth, h: height ?? size.maxHeight);

              return _imgView(uri, img);
            },
          );
  }

  Widget _imgView(Uri uri, ImageProvider img) {
    return OctoImage(
      image: img,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      fadeInDuration: kThemeChangeDuration,
      fadeOutDuration: kThemeChangeDuration,
      errorBuilder: _errorView,
      placeholderBuilder: uri.hasFragment //
          ? OctoPlaceholder.blurHash(Uri.decodeComponent(uri.fragment), fit: BoxFit.cover)
          : _loadingView,
    );
  }

  Widget _errorView(BuildContext context, Object e, StackTrace s) {
    errLog(e, s: s, name: 'IMG');

    return SizedBox(
      width: width,
      height: height,
      child: context.state<ImgErr>(Tuple2(e, s)),
    );
  }

  Widget _loadingView(BuildContext context) => context.state<ImgLoading>();

  static CachedNetworkImageProvider provider0(Uri uri) {
    return CachedNetworkImageProvider(
      '$uri',
      cacheManager: ImgCacheManager.obj,
    );
  }

  static CachedNetworkImageProvider provider(Uri uri, {double w, double h}) {
    if (FileApi.config.imgHost.contains(uri.host)) {
      var query = 'imageView2/1/q/90';

      if (w != null && w != double.infinity) {
        query += '/w/${(w * _pixelRatio).ceil()}';
      }

      if (h != null && h != double.infinity) {
        query += '/h/${(h * _pixelRatio).ceil()}';
      }

      query += '/format/webp';

      uri = uri.replace(query: query);
    }

    uri = uri.removeFragment();

    return CachedNetworkImageProvider(
      '$uri',
      cacheManager: ImgCacheManager.obj,
    );
  }
}
