import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SlideAnimatedView extends StatefulWidget {
  final Widget child;
  final Tuple3<double, double, double> dock;
  final Tuple3<Duration, Duration, Duration> times;
  final VoidCallback onFinish;

  SlideAnimatedView({
    @required this.child,
    @required this.dock,
    @required this.times,
    @required this.onFinish,
  });

  @override
  _SlideAnimatedViewState createState() => _SlideAnimatedViewState();
}

class _SlideAnimatedViewState extends State<SlideAnimatedView> with SingleTickerProviderStateMixin {
  AnimationController _ctrl;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    final _times = widget.times;
    final _dock = widget.dock;

    _ctrl = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
      duration: _times.item1 + _times.item2 + _times.item3,
    );

    _animation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(begin: Offset(_dock.item1, 0), end: Offset(_dock.item2, 0))
              .chain(CurveTween(curve: Curves.easeOutCirc)),
          weight: _times.item1.inMilliseconds.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween(begin: Offset(_dock.item2, 0), end: Offset(_dock.item2, 0)),
          weight: _times.item2.inMilliseconds.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween(begin: Offset(_dock.item2, 0), end: Offset(_dock.item3, 0))
              .chain(CurveTween(curve: Curves.easeOutCirc)),
          weight: _times.item3.inMilliseconds.toDouble(),
        ),
      ],
    ).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onFinish());
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      animation: _ctrl,
      builder: (_, child) => Transform.translate(offset: _animation.value, child: child),
    );
  }
}
