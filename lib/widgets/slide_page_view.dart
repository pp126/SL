import 'package:flutter/material.dart';

class SlidePageView extends StatefulWidget {
  final List<Widget> pages;

  const SlidePageView({Key key, this.pages}) : super(key: key);

  @override
  SlidePageState createState() => SlidePageState();
}

class SlidePageState extends State<SlidePageView> with SingleTickerProviderStateMixin {
  final pages = <int, Widget>{};

  var inIndex = 0, outIndex = 0;

  AnimationController _ctrl;
  List<Animation<Offset>> _animList;

  Animation<Offset> _inAnim;
  Animation<Offset> _outAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: kTabScrollDuration)..forward();

    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.ease);

    _animList = [
      Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(curve),
      Tween<Offset>(begin: Offset.zero, end: Offset(-1, 0)).animate(curve),
      Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(curve),
      Tween<Offset>(begin: Offset.zero, end: Offset(1, 0)).animate(curve),
    ];

    final _pages = widget.pages;
    for (var i = 0; i < _pages.length; ++i) {
      pages[i] = _pages[i];
    }
  }

  go(int toIndex) {
    if (inIndex == toIndex) return;

    setState(() {
      outIndex = inIndex;
      inIndex = toIndex;

      if (inIndex > outIndex) {
        _inAnim = _animList[0];
        _outAnim = _animList[1];
      } else {
        _inAnim = _animList[2];
        _outAnim = _animList[3];
      }

      _ctrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    if (outIndex == inIndex) {
      children = [_X(inIndex, pages[inIndex], true, true)];
    } else {
      children = [
        _X(outIndex, pages[outIndex], true, false, _outAnim),
        _X(inIndex, pages[inIndex], true, true, _inAnim),
      ];
    }

    final offstage = pages.entries
        .where((it) => it.key != inIndex && it.key != outIndex)
        .map((it) => _X(it.key, it.value, false, false));

    children.addAll(offstage);

    return Stack(children: children);
  }
}

class _X extends StatefulWidget {
  final Widget child;
  final bool show, enabled;
  final Animation<Offset> anim;

  _X(int index, this.child, this.show, this.enabled, [this.anim]) : super(key: ValueKey<int>(index));

  @override
  _XState createState() => _XState();
}

class _XState extends State<_X> {
  final _hold = AlwaysStoppedAnimation(Offset.zero);

  @override
  Widget build(BuildContext context) {
    Widget child = Offstage(
      offstage: !widget.show,
      child: TickerMode(
        enabled: widget.enabled,
        child: SlideTransition(
          position: widget.anim ?? _hold,
          child: widget.child,
        ),
      ),
    );

    return child;
  }
}
