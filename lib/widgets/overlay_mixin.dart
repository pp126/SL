import 'dart:async';

import 'package:app/tools.dart';
import 'package:flutter/material.dart';

mixin OverlayMixin<T extends StatefulWidget> on State<T> implements BusStateMixin<T> {
  final _entry = <OverlayEntry>[];

  @override
  void initState() {
    super.initState();

    final children = Map.fromIterable(
      overlay,
      value: (it) {
        Widget child = Material(type: MaterialType.transparency, child: it);

        if (it is IgnorePointerOverlay) {
          child = IgnorePointer(child: child);
        } else if (it is AbsorbPointerOverlay) {
          child = AbsorbPointer(child: child);
        }

        return OverlayEntry(builder: (_) => child);
      },
    );

    if (children.isNotEmpty) {
      Timer.run(() {
        Overlay.of(context, rootOverlay: false) //
            .insertAll(children.values);
      });

      bus(
        CMD.close_overlay,
        (it) => children.remove(it).remove(),
        test: (it) {
          return children.containsKey(it);
        },
      );
    }
  }

  @override
  void dispose() {
    _entry
      ..forEach((it) => it.remove())
      ..clear();

    super.dispose();
  }

  List<Widget> get overlay;
}

mixin IgnorePointerOverlay {}

mixin AbsorbPointerOverlay {}
