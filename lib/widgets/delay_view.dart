import 'dart:async';

import 'package:flutter/material.dart';

class DelayView extends StatefulWidget {
  final Widget child;
  final Duration duration;

  DelayView(this.child, {this.duration = kTabScrollDuration, Key key}) : super(key: key);

  @override
  _DelayViewState createState() => _DelayViewState();
}

class _DelayViewState extends State<DelayView> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(widget.duration, () {
      if (mounted) setState(() => timer = null);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = timer == null;

    return AnimatedOpacity(
      opacity: show ? 1 : 0,
      duration: kThemeChangeDuration,
      curve: Curves.decelerate,
      child: show ? KeepAliveView.$new(widget.child) : null,
    );
  }
}

class KeepAliveView extends StatefulWidget {
  final Widget child;

  KeepAliveView._(this.child);

  static KeepAliveView $new(final Widget child) => KeepAliveView._(child);

  @override
  _KeepAliveViewState createState() => _KeepAliveViewState();
}

class _KeepAliveViewState extends State<KeepAliveView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
