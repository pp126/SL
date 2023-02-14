import 'dart:ui' show window;

import 'package:app/common/theme.dart';
import 'package:app/net/host.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/login/login_page.dart';
import 'package:app/ui/web/web_page.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final px1 = 1.0;

double keyboardHeight() {
  final height = window.viewInsets.bottom / window.devicePixelRatio;

  if (height > 0) {
    Storage.write(PrefKey.KeyboardHeight, height);

    xlog('更新键盘高度配置 => $height');

    return height;
  }

  return Storage.read<double>(PrefKey.KeyboardHeight) ?? 260;
}

Widget debugView({Widget child, Color color = Colors.red}) {
  assert(() {
    child = Container(color: color, child: child);

    return true;
  }());

  return child;
}

extension XText on Widget {
  Container toTagView(
    double height,
    Color bg, {
    double width,
    EdgeInsetsGeometry margin,
    EdgeInsetsGeometry padding,
    double radius,
    BorderRadiusGeometry borderRadius,
    List<Color> colors,
    Widget child,
  }) {
    return xTagView(
      height,
      bg,
      width: width,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.fromLTRB(10, 0, 10, 0),
      radius: radius,
      borderRadius: borderRadius,
      colors: colors,
      child: child ?? this,
    );
  }

  Container toAssImg(double height, String bg,
      {double width,
      EdgeInsetsGeometry margin,
      EdgeInsetsGeometry padding,
      Alignment alignment,
      int quarterTurns,
      BoxFit boxFit: BoxFit.fitHeight}) {
    return Container(
      height: height,
      width: width,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Stack(
        alignment: alignment ?? Alignment.center,
        children: [
          RotatedBox(
              quarterTurns: quarterTurns ?? 0,
              child: SvgPicture.asset(
                SVG.$('$bg'),
                height: height,
                width: width,
                fit: boxFit,
              )),
          this,
        ],
      ),
    );
  }

  Widget toWarp(
      {EdgeInsetsGeometry margin,
      EdgeInsetsGeometry padding,
      Alignment alignment,
      double radius,
      Color color}) {
    return Padding(
        padding: margin ?? EdgeInsets.all(0),
        child: Material(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 12)),
            child: Container(
                padding: padding ?? EdgeInsets.all(0),
                alignment: alignment ?? Alignment.topLeft,
                child: this)));
  }

  Widget toWarpOnle(
      {EdgeInsetsGeometry margin,
      EdgeInsetsGeometry padding,
      Alignment alignment,
      BorderRadiusGeometry radius,
      Color color}) {
    return Padding(
        padding: margin ?? EdgeInsets.all(0),
        child: Material(
            color: color ?? Colors.white,
            borderRadius: radius ?? BorderRadius.all(Radius.circular(12)),
            child: Container(
                padding: padding ?? EdgeInsets.all(0),
                alignment: alignment ?? Alignment.topLeft,
                child: this)));
  }

  Widget toBtn(
    double height,
    Color bg, {
    double width,
    EdgeInsetsGeometry margin,
    EdgeInsetsGeometry padding,
    Color splashColor,
    double radius = 100,
    BorderRadiusGeometry borderRadius,
    List<Color> colors,
    GestureTapCallback onTap,
    bool autoSize = false,
  }) {
    return xFlatButton(
      height,
      bg,
      width: width,
      margin: margin,
      padding: padding,
      splashColor: splashColor,
      radius: radius,
      borderRadius: borderRadius,
      colors: colors,
      onTap: onTap,
      child: this,
      autoSize: autoSize,
    );
  }
}

Widget xTagView(
  double height,
  Color bg, {
  double width,
  EdgeInsetsGeometry margin,
  EdgeInsetsGeometry padding,
  double radius,
  BorderRadiusGeometry borderRadius,
  List<Color> colors,
  Widget child,
  bool autoSize = false,
}) {
  borderRadius =
      borderRadius ?? BorderRadius.all(Radius.circular(radius ?? 100));
  BoxDecoration boxDecoration =
      BoxDecoration(color: bg, borderRadius: borderRadius);
  if (colors != null) {
    boxDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius);
  }

  return Container(
    height: height,
    width: width,
    alignment: autoSize ? null : Alignment.center,
    constraints: autoSize
        ? BoxConstraints(
            minHeight: 0,
            minWidth: 0,
          )
        : null,
    margin: margin ?? EdgeInsets.zero,
    padding: padding ?? EdgeInsets.only(),
    decoration: boxDecoration,
    child: child,
  );
}

Widget xFlatButton(
  double height,
  Color bg, {
  double width,
  EdgeInsetsGeometry margin,
  EdgeInsetsGeometry padding,
  Color splashColor,
  double radius = 100,
  BorderRadiusGeometry borderRadius,
  List<Color> colors,
  GestureTapCallback onTap,
  AlignmentGeometry alignment,
  Widget child,
  bool autoSize = false,
}) {
  var r = radius ?? 100;
  if (bg == AppPalette.primary) {
    ///为主题色时，防止看不清
    splashColor = AppPalette.subSplash;
  }

  child = Container(
    constraints: autoSize
        ? BoxConstraints(
            minHeight: 0,
            minWidth: 0,
          )
        : null,
    alignment: autoSize ? null : Alignment.center,
    height: height,
    padding: padding ?? EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: child,
  );
  if (onTap != null) {
    child = Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(r))),
      child: InkWell(
        splashColor: splashColor,
        borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(r)),
        onTap: onTap,
        child: child,
      ),
    );
  }
  return xTagView(
    height,
    bg,
    width: width,
    margin: margin,
    padding: EdgeInsets.zero,
    radius: radius,
    borderRadius: borderRadius,
    colors: colors,
    autoSize: autoSize,
    child: child,
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

extension XBuildContext on BuildContext {
  Future showDownDialog(widget) {
    return showGeneralDialog(
      context: this,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      transitionDuration: Duration(milliseconds: 200),
      transitionBuilder: (ctx, animation, _, child) {
        return FractionalTranslation(
          translation: Offset(0, 1 - animation.value),
          child: child,
        );
      },
      pageBuilder: (_, __, ___) => widget,
    );
  }
}

Widget xTermsOfServiceWidget() {
  return Container(
    height: 60,
    alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ObxValue<RxBool>(
          (it) {
            return Radio(
              value: it.value,
              toggleable: true,
              groupValue: true,
              onChanged: (b) {
                if (b ?? false) {
                  assert(false);
                } else {
                  Storage.write(PrefKey.AgreementConfirm, false);

                  DialogUtils.showAgreementDialog(LoginPage.agreementRx);
                }
              },
            );
          },
          LoginPage.agreementRx,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '登录/注册即同意'),
              TextSpan(
                  text: '“用户协议”',
                  style: TextStyle(color: AppPalette.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.to(AppWebPage(
                          title: '用户协议',
                          url: 'http://${host.host}/agreement/user.html',
                        ))),
              TextSpan(text: '与'),
              TextSpan(
                  text: '“隐私协议”',
                  style: TextStyle(color: AppPalette.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Get.to(AppWebPage(
                          title: '隐私协议',
                          url: 'http://${host.host}/agreement/userPrivacy.html',
                        ))),
            ],
          ),
          style: TextStyle(fontSize: 12, color: AppPalette.dark),
        ),
      ],
    ),
  );
}

Widget xHalfBackgroundView({
  Color bgColor = AppPalette.background,
  Color colorA = Colors.transparent,
  Color colorB = Colors.white,
  BorderRadiusGeometry borderRadius,
  Widget child,
}) {
  return Stack(
    children: [
      Positioned.fill(
        child: Container(
          color: bgColor ?? AppPalette.background,
        ),
      ),
      Column(
        children: [
          Expanded(
              child: Container(
            color: colorA ?? Colors.transparent,
          )),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                color: colorB ?? Colors.white,
                borderRadius: borderRadius ??
                    BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )),
          )),
        ],
      ),
      Positioned.fill(
        child: child,
      )
    ],
  );
}

extension XWidget on Widget {
  Overlay toOverlay() =>
      Overlay(initialEntries: [OverlayEntry(builder: (_) => this)]);
}

Widget $AppBubble({Widget child, Color color, BubbleNip nip}) {
  return LimitedBox(
    maxWidth: Get.width * 220 / 375,
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Bubble(
        nip: nip,
        color: color,
        padding: BubbleEdges.all(0),
        child: Material(type: MaterialType.transparency, child: child),
        style: BubbleStyle(
            radius: Radius.circular(12),
            elevation: 0,
            nipOffset: 8,
            nipRadius: 2),
      ),
    ),
  );
}
