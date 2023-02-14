import 'package:flutter/material.dart';

import '../widgets.dart';

class DefaultPageView extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> pages;
  final ValueChanged<int> onPageChanged;
  final bool tabScrollable;
  final int initialIndex;
  final double tabHeight;

  DefaultPageView(
    this.tabs,
    this.pages, {
    this.onPageChanged,
    this.tabScrollable,
    this.initialIndex = 0,
    this.tabHeight = 40,
    Key key,
  }) : super(key: key);

  @override
  DefaultPageViewState createState() => DefaultPageViewState();

  static List<Tab> createTabs(Iterable<String> keys) {
    return keys.map((it) => Tab(text: it)).toList(growable: false);
  }
}

class DefaultPageViewState extends State<DefaultPageView> with SingleTickerProviderStateMixin {
  int _length;
  bool tabScrollable;
  TabController ctrl;

  @override
  void initState() {
    super.initState();
    _length = widget.tabs.length;

    tabScrollable = widget.tabScrollable ?? _length > 4;

    final index = widget.initialIndex;

    ctrl = TabController(length: _length, initialIndex: index, vsync: this);

    final onPageChanged = widget.onPageChanged;
    if (onPageChanged != null) {
      ctrl.addListener(() => onPageChanged(ctrl.index));
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    if (_length == 1) return pages[0];

    final _pages = pages.map(KeepAliveView.$new).toList(growable: false);

    final tabHeight = widget.tabHeight;

    return Stack(
      children: [
        Positioned.fill(
          top: tabHeight,
          child: TabBarView(controller: ctrl, children: _pages),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: tabHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: ctrl,
              tabs: widget.tabs,
              isScrollable: tabScrollable,
              labelPadding: tabScrollable ? null : EdgeInsets.zero,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }
}
