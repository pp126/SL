import 'dart:io';

import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class SVGAIcon extends StatelessWidget {
  final String icon;

  SVGAIcon({this.icon});

  @override
  Widget build(BuildContext context) => SVGAImg(assets: SVGA.$(icon));
}

class SVGAImg extends StatelessWidget {
  final File file;
  final String assets;

  SVGAImg({this.file, this.assets});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SVGAImg(file: file, assets: assets),
    );
  }
}
