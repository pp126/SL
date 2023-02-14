import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_jully_button.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart' as badges;

class AppFab extends StatelessWidget {
  final VoidCallback onTap;

  AppFab(this.onTap);

  final double size = 60;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, size / 2 - 12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppPalette.primary.withAlpha(0x33),
              blurRadius: 10,
              spreadRadius: -6,
            ),
          ],
        ),
        child: JellyButton(
          checked: true,
          checkedImgAsset: SVG.$('main/more'),
          unCheckedImgAsset: SVG.$('main/more'),
          duration: Duration(seconds: 1),
          size: Size.square(size),
          onTap: onTap,
        ),
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  final RxInt selector;
  final List<NavBarItem> items;

  NavBar({this.selector, this.items});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: views,
        ),
      ),
    );
  }

  List<Widget> get views {
    var i = 0;

    return items.map((it) {
      Widget child;

      if (it != null) {
        final curr = i++;

        child = Obx(() {
          return InkResponse(
            child: it.toView(curr == selector.value),
            onTap: () => selector.value = curr,
          );
        });
      }

      return AspectRatio(aspectRatio: 1, child: child);
      // return Expanded(child: child ?? SizedBox.shrink());
    }).toList(growable: false);
  }
}

class NavBarItem {
  final String label;
  final ValueNotifier<int> badge;

  NavBarItem({this.label, this.badge});

  Widget toView(bool b) {
    Widget icon = SvgPicture.asset(
      SVG.$('main/nav_$label${b ? '_p' : ''}'),
      width: 32,
      height: 33,
    );

    if (badge != null) {
      final _icon = icon;

      icon = NotifierView(badge, (num) {
        final radius = BorderRadius.horizontal(
          left: Radius.circular(999),
          right: Radius.circular(999),
        );

        return badges.Badge(
          child: _icon,
          showBadge: num > 0,
          ignorePointer: true,
          position: BadgePosition.topEnd(top: -2, end: -4),
          badgeContent: Text(
            '${num > 99 ? '99+' : num}',
            style: TextStyle(fontSize: 8, color: Colors.white),
          ),
        );
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        AnimatedDefaultTextStyle(
          duration: kThemeChangeDuration,
          style: TextStyle(
            fontSize: 10,
            color: b ? AppPalette.txtDark : AppPalette.tips,
            fontWeight: b ? fw$SemiBold : fw$Regular,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
