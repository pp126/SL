import 'package:flutter/material.dart';

class GridLayout extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing, crossAxisSpacing;
  final EdgeInsetsGeometry padding;

  GridLayout({
    @required this.children,
    @required this.crossAxisCount,
    @required this.childAspectRatio,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding ?? EdgeInsets.zero,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      children: children,
    );
  }
}
