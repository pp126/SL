import 'dart:async';

import 'package:app/net/ws_event.dart';
import 'package:app/tools.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

typedef void OnData<T>(T data);

class CmdEvent<T> {
  final String action;
  final T data;

  CmdEvent(this.action, [this.data]);

  @override
  String toString() => 'CmdEvent{action: $action, data: $data}';
}

final _bus = EventBus();

class Bus {
  Bus._();

  static StreamSubscription<T> sub<T>(String event, OnData<T> f, {bool test(T event)}) {
    var stream = _bus //
        .on<CmdEvent<T>>()
        .where((it) => it.action == event)
        .map((it) => it.data);

    if (test != null) {
      stream = stream.where(test);
    }

    return stream.listen(f);
  }

  static void send<T>(String event, [T data]) => fire(CmdEvent<T>(event, data));

  static StreamSubscription<T> on<T>(OnData<T> onData, {bool test(T event)}) {
    var stream = _bus.on<T>();

    if (test != null) {
      stream = stream.where(test);
    }

    return stream.listen(onData);
  }

  static void fire(event) {
    xlog('FIRE => $event', name: 'BUS');

    // todo 由于消息返回在前，订阅在后，为了避免自己进房间看不到动态消息及动画，暂时延时500ms推送进入房间的消息
    if (event is ChatRoomMemberIn) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _bus.fire(event);
      });
    } else
      _bus.fire(event);
  }
}

mixin BusStateMixin<T extends StatefulWidget> on State<T> {
  final _listeners = <StreamSubscription>[];

  void bus<T>(String event, OnData<T> call, {bool test(T event)}) {
    _listeners.add(Bus.sub<T>(event, call, test: test));
  }

  void on<T>(OnData<T> call, {bool test(T event)}) {
    _listeners.add(Bus.on<T>(call, test: test));
  }

  @override
  void dispose() {
    _listeners
      ..forEach((it) => it.cancel())
      ..clear();

    super.dispose();
  }
}

mixin BusDisposableMixin on GetLifeCycleBase {
  final _listeners = <StreamSubscription>[];

  void bus<T>(String event, OnData<T> call, {bool test(T event)}) {
    _listeners.add(Bus.sub<T>(event, call, test: test));
  }

  void on<T>(OnData<T> call, {bool test(T event)}) {
    _listeners.add(Bus.on<T>(call, test: test));
  }

  @override
  @mustCallSuper
  void onClose() {
    _listeners
      ..forEach((it) => it.cancel())
      ..clear();
  }
}
