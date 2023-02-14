import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meta/meta.dart';

Widget get _defaultHead {
  final dec = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEFEDFF), Colors.white],
    ),
  );

  return FittedBox(
    fit: BoxFit.contain,
    child: Container(
      width: 100,
      height: 100,
      decoration: dec,
      alignment: Alignment.center,
      // child: SvgPicture.asset(SVG.$('main/nav_首页_p'), width: 60, height: 60),
      child: Image.asset(IMG.$('header', 'jpg')),
    ),
  );
}

class AvatarView extends StatelessWidget {
  final String url;
  final double size;
  final BorderSide side;

  AvatarView({@required this.url, this.size = 82, this.side = BorderSide.none});

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      shape: CircleBorder(side: side),
      clipBehavior: Clip.antiAlias,
      type: MaterialType.transparency,
      child: Container(
        width: size,
        height: size,
        child: ConfigImgState(
          errView: _defaultHead,
          loading: _defaultHead,
          child: NetImage(url, fit: BoxFit.cover),
        ),
      ),
    );

    return child;
  }
}

class RectAvatarView extends StatelessWidget {
  final String url;
  final double size;
  final BorderRadiusGeometry borderRadius;
  final int uid;
  final double radius;

  RectAvatarView(
      {@required this.url,
      this.size = 82,
      this.borderRadius,
      this.uid,
      this.radius = 12});

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: size,
        height: size,
        child: ConfigImgState(
          errView: _defaultHead,
          loading: _defaultHead,
          child: NetImage(url, fit: BoxFit.cover),
        ),
      ),
    );

    if (uid != null) {
      child = GestureDetector(
          onTap: () => Get.to(UserPage(uid: uid), preventDuplicates: false),
          child: child);
    }

    return child;
  }
}

class SelfView extends StatelessWidget {
  final bool circle;
  final double size;
  final BorderSide side;

  SelfView({this.size = 82, this.side = BorderSide.none, this.circle = true});

  @override
  Widget build(BuildContext context) {
    return OAuthCtrl.use(
      builder: (it) {
        final url = it['avatar'];

        return circle //
            ? AvatarView(url: url, size: size, side: side)
            : RectAvatarView(url: url, size: size);
      },
    );
  }
}
