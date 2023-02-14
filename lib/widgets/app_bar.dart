import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/custom_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuple/tuple.dart';

final double $ToolbarHeight = 44;

AppBar xAppBar(title, {action, TextStyle style, Widget leading, Color bgColor}) {
  List<Widget> actions;

  if (action is List) {
    actions = [...action, Spacing.w8];
  } else if (action is Widget) {
    actions = [action, Spacing.w8];
  }

  Widget _title, _flexibleSpace;

  if (title is String) {
    _title = Text(
      title,
      style: style,
    );
  } else if (title is Widget) {
    _flexibleSpace = title;
  } else {
    assert(title == null);
  }

  double titleSpacing;

  if (Get.key.currentState.canPop() && leading == null) {
    leading = xBackBtn();

    titleSpacing = 0;
  } else {
    titleSpacing = NavigationToolbar.kMiddleSpacing;
  }

  return AppBar(
    leading: leading,
    title: _title,
    flexibleSpace: _flexibleSpace,
    actions: actions,
    titleSpacing: titleSpacing,
    toolbarHeight: $ToolbarHeight,
    backgroundColor: bgColor,
  );
}

Widget xAppBar$TabBar(
  List<Widget> tabs, {
  Tuple2<TextStyle, TextStyle> labelStyle,
  Color labelColor,
  Decoration indicator,
  bool isScrollable,
  AlignmentGeometry alignment = Alignment.bottomCenter,
}) {
  final fixMargin = indicator is APPTabIndicator;
  final defaultMargin = EdgeInsets.symmetric(horizontal: 8);

  return Align(
    alignment: alignment,
    child: Container(
      height: $ToolbarHeight,
      margin: fixMargin ? EdgeInsets.symmetric(horizontal: 16) : defaultMargin,
      child: Theme(
        data: Get.theme.copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: TabBar(
          labelPadding: fixMargin ? EdgeInsets.only(right: 16) : defaultMargin,
          isScrollable: isScrollable ?? true,
          labelColor: labelColor ?? AppPalette.primary,
          unselectedLabelColor: AppPalette.hint,
          labelStyle: labelStyle?.item1 ?? TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          unselectedLabelStyle: labelStyle?.item2 ?? TextStyle(fontSize: 16),
          indicator: indicator,
          tabs: tabs,
        ),
      ),
    ),
  );
}

Widget xBackBtn({Color color}) {
  return IconButton(
    iconSize: 32,
    icon: ImageIcon(AssetImage(IMG.$('ic_back')), color: color),
    onPressed: Get.back,
  );
}

Widget xActionBtn({Key key, Widget icon, VoidCallback onPressed}) {
  return IconButton(
    padding: EdgeInsets.zero,
    key: key,
    icon: icon,
    onPressed: onPressed,
  );
}

extension ActionBtn$String on String {
  Widget toImgActionBtn({Key key, VoidCallback onPressed}) {
    return xActionBtn(
      key: key,
      onPressed: onPressed,
      icon: Image.asset(IMG.$(this), scale: 3),
    );
  }

  Widget toSvgActionBtn({Key key, VoidCallback onPressed, Color color, double width, double height}) {
    return xActionBtn(
      key: key,
      onPressed: onPressed,
      icon: SvgPicture.asset(SVG.$(this), color: color, width: width, height: height),
    );
  }

  Widget toTxtActionBtn({Key key, VoidCallback onPressed}) {
    return xActionBtn(
      key: key,
      onPressed: onPressed,
      icon: Container(
        width: 57,
        height: 24,
        decoration: ShapeDecoration(color: AppPalette.primary, shape: StadiumBorder()),
        alignment: Alignment.center,
        child: Text(
          this,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget toTxtActionBtn2({Key key, VoidCallback onPressed}) {
    return xActionBtn(
      key: key,
      onPressed: onPressed,
      icon: Container(
        width: 57,
        height: 24,
        decoration: ShapeDecoration(color: AppPalette.txtWhite, shape: StadiumBorder()),
        alignment: Alignment.center,
        child: Text(
          this,
          style: TextStyle(fontSize: 12, color: AppPalette.primary),
        ),
      ),
    );
  }
}
