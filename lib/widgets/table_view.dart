import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

typedef PreferredSize CreateDivider();

class TableView extends StatelessWidget {
  final List<TableGroup> items;
  final double spacing;
  final double itemExtent;

  TableView(this.items, {this.spacing = 8, this.itemExtent = 48});

  List<Widget> createGroup() {
    final children = <Widget>[];

    for (final item in items) {
      Widget child = Column(children: createItems(item.items));


      child = Material(
        color: item.backgroundColor,
        textStyle: item.textStyle,
        borderRadius: item.borderRadius,
        clipBehavior: Clip.antiAlias,
        child: child,
      );

      child = Container(
        margin: item.margin ?? EdgeInsets.only(),
        child: child,
      );


      final divider = item.createDivider();
      if (divider != null) {
        final height = divider.preferredSize.height;
        final children = <Widget>[child];

        for (var i = 1; i < item.items.length; ++i) {
          children.add(
            Positioned(
              top: itemExtent * i - height / 2,
              left: 0,
              right: 0,
              height: height,
              child: divider,
            ),
          );
        }

        child = Stack(
          alignment: Alignment.topCenter,
          children: children,
        );
      }

      if (spacing != null) {
        child = Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: child,
        );
      }

      children.add(child);
    }

    return children;
  }

  List<Widget> createItems(List<TableItem> items) {
    final rowList = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      final children = <Widget>[];
      Widget row = InkWell(
        child: SizedBox(
          child: Row(children: children),
          height: itemExtent,
        ),
        onTap: item.onTap,
      );

      if (item.icon != null) {
        children.add(
          Container(
            margin: EdgeInsets.only(left: 19, right: 8),
            child: item.icon,
          ),
        );
      } else {
        children.add(Spacing.w16);
      }

      if (item.title != null) {
        children.add(Text(item.title));
      }

      children.add(Spacing.exp);

      if (item.tips != null) {
        children.add(Text(item.tips,style: TextStyle(fontSize: 10,color: AppPalette.primary),));
      }

      if (item.action != null) {
        children.add(item.action);
      } else if (item.onTap != null) {
        children.add(Container(
          margin: EdgeInsets.only(left: 8, right: 16),
          child: RightArrowIcon(),
        ));
      }

      rowList.add(row);
    }

    return rowList;
  }

  @override
  Widget build(BuildContext context) => Column(children: createGroup());
}

class TableGroup {
  final List<TableItem> items;
  final Color backgroundColor;
  final TextStyle textStyle;
  final BorderRadius borderRadius;
  final CreateDivider createDivider;
  final EdgeInsetsGeometry margin;

  TableGroup(
    this.items, {
    this.backgroundColor,
    this.textStyle,
    this.borderRadius,
    this.margin,
    this.createDivider = _createDivider,
  });

  static PreferredSize _createDivider() {
    return PreferredSize(
      preferredSize: Size.fromHeight(px1),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Divider(),
      ),
    );
  }
}

class TableItem {
  final Widget icon;
  final String title;
  final Widget action;
  final String tips;
  final VoidCallback onTap;

  TableItem({this.icon, this.title, this.action,this.tips, this.onTap});
}
