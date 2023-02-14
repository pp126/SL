import 'package:app/common/theme.dart';
import 'package:app/ui/app.dart';
import 'package:app/ui/common/app_simple_dialog.dart';
import 'package:app/ui/mine/wallet/wallet_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_rx/get_rx.dart';

extension GetExtension on GetInterface {
  Future<T> showBottomSheet<T>(
    Widget child, {
    bool isScrollControlled = true,
    Color bgColor = Colors.white,
    EdgeInsets safeAreaMinimum = EdgeInsets.zero,
  }) {
    return Get.bottomSheet(
      SafeArea(child: child, minimum: safeAreaMinimum),
      backgroundColor: bgColor,
      isScrollControlled: isScrollControlled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      clipBehavior: Clip.none,
    );
  }

  Future<String> showInputDialog({String title = '请输入', String initial, TextInputType keyboardType}) {
    final ctrl = TextEditingController(text: initial);

    return showCupertinoDialog(
      context: Get.context,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CupertinoTextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: keyboardType,
              clearButtonMode: OverlayVisibilityMode.always,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () => Get.back(result: ctrl.text),
            ),
          ],
        );
      },
    );
  }

  void rechargeDialog(String tips) async {
    if (await Get.simpleDialog(msg: tips, okLabel: '去充值') == '去充值') {
      Get.to(WalletPage());
    }
  }

  Future<String> simpleDialog({String msg = '请选择', String okLabel = '确定', Widget content}) {
    content ??= Text(
      msg,
      style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
    );

    return Get.dialog(
      AppSimpleDialog(
        content: Container(
          height: 88,
          alignment: Alignment.center,
          child: content,
        ),
        actions: [
          OkDialogAction(
            title: okLabel,
            onTap: () => Get.back(result: okLabel),
          ),
          CancelDialogAction(),
        ],
      ),
    );
  }

  Future<void> alertDialog(String msg) {
    return Get.dialog(
      AppSimpleDialog(
        content: Container(
          height: 88,
          alignment: Alignment.center,
          child: Text(
            msg,
            style: TextStyle(fontSize: 14, color: AppPalette.txtDark),
          ),
        ),
        actions: [OkDialogAction(onTap: Get.back)],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> infoDialog({String title, String msg}) {
    return Get.dialog(
      AppSimpleDialog(
        title: title,
        content: Container(
          height: 350,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              msg,
              style: TextStyle(fontSize: 13, color: AppPalette.txtDark),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> showActionSheet(Iterable<String> actions) {
    CupertinoActionSheetAction itemBuilder(String it) {
      return CupertinoActionSheetAction(
        child: Text(it),
        onPressed: () => Get.back(result: it),
      );
    }

    final child = CupertinoActionSheet(
      actions: [for (final it in actions) itemBuilder(it)],
      cancelButton: CupertinoActionSheetAction(
        child: Text('取消'),
        onPressed: Get.back,
      ),
    );

    return showCupertinoModalPopup<String>(context: Get.context, builder: (x) => child);
  }

  OverlayEntry insertOverlay(Widget child) {
    final entry = OverlayEntry(builder: (_) => child);

    Get.key.currentState.overlay.insert(entry);

    return entry;
  }

  void untilByCtx(BuildContext ctx) {
    final self = ModalRoute.of(ctx);

    if (self == null) {
      assert(true, '未知情况');

      Get.offAll(Root());
    } else {
      var b = false;

      Get.until((route) {
        final tmp = b;

        if (route == self) {
          b = true;
        }

        return tmp;
      });
    }
  }
}

mixin GetStateMixin<T extends StatefulWidget> on State<T> {
  final _types = <Function>[];

  bindGet<S>(S dependency) {
    Get.put<S>(dependency, permanent: true);

    _types.add(() => Get.delete<S>(force: true));
  }

  @override
  void dispose() {
    _types
      ..forEach((it) => it())
      ..clear();

    super.dispose();
  }
}

extension XRxMap<K, V> on RxMap<K, V> {
  bool get isNotBlank => !isEmpty;

  bool get isNullOrBlank {
    try {
      return isEmpty;
    } catch (e) {
      return false;
    }
  }
}
