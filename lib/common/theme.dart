import 'dart:math';

import 'package:app/tools.dart';
import 'package:app/tools/view.dart';
import 'package:flutter/material.dart';

final $theme = _default();

ThemeData _default() {
  return ThemeData(
    primarySwatch: createMaterialColor(AppPalette.primary),
    scaffoldBackgroundColor: Colors.white,
    splashFactory: InkRipple.splashFactory,
    //水波纹
    splashColor: AppPalette.splash,
    //水波纹
    highlightColor: AppPalette.splash,
    accentColor: AppPalette.primary,
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(),
      labelColor: AppPalette.primary,
      unselectedLabelColor: AppPalette.hint,
      labelStyle: TextStyle(fontSize: 16),
      unselectedLabelStyle: TextStyle(fontSize: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      selectedItemColor: AppPalette.dark,
      unselectedItemColor: AppPalette.tips,
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 10),
      backgroundColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 16, color: AppPalette.dark, fontWeight: fw$SemiBold),
      ),
      iconTheme: IconThemeData(color: AppPalette.dark),
      brightness: Brightness.light,
      color: AppPalette.background,
      centerTitle: false,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(space: px1, thickness: px1, color: AppPalette.divider),
    cardTheme: CardTheme(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    platform: TargetPlatform.android,
  );
}

ThemeData get themeDark {
  final oldTheme = Get.theme;

  return oldTheme.copyWith(
    scaffoldBackgroundColor: AppPalette.dark,
    appBarTheme: oldTheme.appBarTheme.copyWith(
      textTheme: oldTheme.appBarTheme.textTheme.copyWith(
        headline6: oldTheme.appBarTheme.textTheme.headline6.copyWith(
          color: Colors.white,
        ),
      ),
      iconTheme: oldTheme.appBarTheme.iconTheme.copyWith(
        color: Colors.white,
      ),
      brightness: Brightness.dark,
      color: AppPalette.dark,
    ),
  );
}

final fw$Regular = FontWeight.w500;
final fw$SemiBold = FontWeight.w600;

class AppPalette {
  AppPalette._();

  //App
  static const primary = Color(0xFF7C66FF);
  static const dark = Color(0xFF252142);
  static const pink = Color(0xFFFF607C);
  static const hint = Color(0xFFCBC8DC);
  static const tips = Color(0xFF908DA8);
  static const divider = Color(0xFFF8F7FC);
  static const background = Color(0xFFFAF9FE);
  static const splash = Color(0x1A7C66FF);
  static const subSplash = Color(0xFF4528ED);

  //Txt
  static const txtDark = Color(0xFF252142);
  static const txtWhite = Color(0xFFF1EEFF);
  static const txtPrimary = Color(0xFFA798FF);
  static const txtRoomChat = Color(0xFF39FDFF);
  static const txtGold = Color(0xFFFFE42F);

  //
  static const c3 = Color(0xFF333333);
  static const c6 = Color(0xFF666666);
  static const c9 = Color(0xFF999999);
  static const barrier = Color(0x80000000);
  static const transparent = Color(0x00000001);

  static const sheetWhite = Color(0xF4FBFBFB);
  static const sheetDark = Color(0xF4252142);

  static Color get random {
    final r = Random.secure();

    return Color.fromARGB(0xFF, r.nextInt(0xFF), r.nextInt(0xFF), r.nextInt(0xFF));
  }
}

class AppSize {
  AppSize._();

  static const safeAreaMini = EdgeInsets.only(bottom: 20);
}
