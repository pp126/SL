import 'dart:async';

import 'package:app/tools.dart';
import 'package:flutter/material.dart';

mixin TimerDisposableMixin on GetLifeCycleBase {
  final _timer = <Timer>[];

  void addTimer(Timer timer) => _timer.add(timer);

  void cancelTimer() {
    _timer
      ..forEach((it) => it.cancel())
      ..clear();
  }

  @override
  @mustCallSuper
  void onClose() {
    cancelTimer();

    super.onClose();
  }
}

mixin TimerStateMixin<T extends StatefulWidget> on State<T> {
  final _timer = <Timer>[];

  void addTimer(Timer timer) => _timer.add(timer);

  void cancelTimer() {
    _timer
      ..forEach((it) => it.cancel())
      ..clear();
  }

  @override
  @mustCallSuper
  void dispose() {
    cancelTimer();

    super.dispose();
  }
}
