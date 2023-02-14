import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/network_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNetImage extends StatelessWidget {
  final String netImageUrl;
  final double defaultImageWidth;
  final double defaultImageHeight;
  String defaultImage;
  final double radius;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final bool isHead;

  AppNetImage({
    this.netImageUrl = '',
    this.defaultImageWidth = double.infinity,
    this.defaultImageHeight = double.infinity,
    this.defaultImage,
    this.fit = BoxFit.cover,
    this.radius = 10.0,
    this.borderRadius,
    this.isHead = false,
  });

  @override
  Widget build(BuildContext context) {
    if(defaultImage == null){
      defaultImage = isHead?IMG.$('default_head'):SVG.$('default');
    }
    bool isEmpty = netImageUrl == null || netImageUrl.isEmpty;
    bool isLocal = !isEmpty && !netImageUrl.contains('http') && netImageUrl.contains('images/');

    Widget child = ClipRRect(
      borderRadius: borderRadius??BorderRadius.all(Radius.circular(radius)),
      child: Container(
        width: defaultImageWidth,
        height: defaultImageHeight,
        child: isLocal
            ? imageItem(netImageUrl)
            : ConfigImgState(
                loading: buildDefaultImage(),
                errView: buildDefaultImage(),
                child: NetImage(netImageUrl, fit: fit),
              ),
      ),
    );

    return child;
  }
  buildDefaultImage(){
    return imageItem(defaultImage);
  }

  imageItem(String path){
    return path.contains('.svg')?SvgPicture.asset(
      path,
      fit: fit,
    ):Image.asset(
      defaultImage,
      fit: BoxFit.fill,
    );
  }
}
