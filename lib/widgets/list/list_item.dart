import 'package:flutter/material.dart';

abstract class ListItem<T> extends StatelessWidget {
  final T item;

  ListItem(this.item, {Key key}) : super(key: key ?? ObjectKey(item));

  @override
  Widget build(BuildContext context) => itemBuild(context, item);

  Widget itemBuild(BuildContext context, T item);
}
