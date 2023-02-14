import 'package:app/net/api.dart';
import 'package:app/ui/message/user_item_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class FriendListView extends StatefulWidget {
  final bool showFans;
  final bool showSend;
  final bool showLike;
  FriendListView({
    this.showFans = false,
    this.showSend = false,
    this.showLike = false,
  });
  @override
  _FriendListViewState createState() => _FriendListViewState();
}

class _FriendListViewState extends NetList<Map, FriendListView> {
  @override
  Future fetch() => Api.User.friend();

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => UserItemView(
      item,
    showFans: widget.showFans,
    showLike: widget.showLike,
    showSend: widget.showSend,
  );

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(height: 1, indent: 73, endIndent: 15),
    );
  }
}
