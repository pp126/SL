import 'package:flutter/cupertino.dart';

class TabBarPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final double height;

  TabBarPersistentHeaderDelegate(this.tabBar, this.height);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => tabBar;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}