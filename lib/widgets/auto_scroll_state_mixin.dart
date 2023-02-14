import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin AutoScrollStateMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  final listCtrl = ScrollController();

  Timer _timer;
  AnimationController _animCtrl;

  bool _autoScroll = true;
  DateTime _nextScroll;

  void autoScroll() {
    if (_autoScroll) {
      _timer?.cancel();

      final now = DateTime.now();
      _nextScroll ??= now.add(Duration(milliseconds: 100));

      _timer = Timer(_nextScroll.difference(now), _scrollToEnd);
    }
  }

  void _scrollToEnd() async {
    await _animCtrl.forward();

    _animCtrl.reset();

    _nextScroll = null;
  }

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      duration: kTabScrollDuration,
      vsync: this,
    );

    _animCtrl.addListener(() {
      if (listCtrl.hasClients) {
        final position = listCtrl.position;

        final max = position.maxScrollExtent;
        final now = position.pixels;
        final offs = max - now;

        if (offs > 0) {
          listCtrl.jumpTo(offs * _animCtrl.value + now);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();

    super.dispose();
  }

  Widget wrapList(Widget child) {
    return NotificationListener(
      onNotification: (UserScrollNotification event) {
        if (event.direction == ScrollDirection.forward) {
          if (_autoScroll) {
            _timer?.cancel();
            _nextScroll = null;

            _autoScroll = false;
          }
        } else {
          final metrics = event.metrics;
          if (metrics is ScrollMetrics) {
            final newValue = metrics.maxScrollExtent == metrics.pixels;
            if (_autoScroll != newValue) _autoScroll = newValue;
          }
        }

        return true;
      },
      child: child,
    );
  }
}
