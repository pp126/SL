import 'package:app/tools.dart';
import 'package:flutter/material.dart';

hideKeyboard() {
  try {
    FocusManager.instance.primaryFocus.unfocus();
  } catch (e, s) {
    errLog(e, s: s);
  }
}

GestureDetector $Keyboard(Widget child, {VoidCallback func}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    child: child,
    onTap: () async {
      await hideKeyboard();

      if (func != null) func();
    },
  );
}
