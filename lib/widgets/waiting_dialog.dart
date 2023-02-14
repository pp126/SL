import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitingOverlay extends StatelessWidget {
  const WaitingOverlay() : super(key: const Key('WaitingOverlay'));

  @override
  Widget build(BuildContext context) {
    return GetX<WaitingCtrl>(
      builder: (it) {
        return Offstage(
          offstage: it._offstage.value,
          child: Get.find<AppWaiting>(),
        );
      },
    );
  }
}

class AppWaiting extends StatelessWidget {
  const AppWaiting();

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      '请稍候',
      style: TextStyle(fontSize: 13, color: Color(0xFFEBEBF5)),
    );

    final indicator = Theme(
      data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
      child: CupertinoActivityIndicator(radius: 13),
    );

    child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [indicator, Spacing.h8, child],
    );

    child = SizedBox(width: 96, height: 96, child: child);

    child = Material(
      color: Color(0xB2171717),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: child,
    );

    child = AbsorbPointer(child: Center(child: child));

    return child;
  }
}

class WaitingCtrl extends GetxService {
  final _offstage = RxBool(true);

  bool get isShow => !_offstage.value;

  show() => _offstage.value = false;

  hidden() => _offstage.value = true;

  @override
  void onInit() {
    super.onInit();

    Get.insertOverlay(WaitingOverlay());
  }

  static WaitingCtrl get obj => Get.find();
}
