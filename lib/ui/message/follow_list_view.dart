import 'package:app/net/api.dart';
import 'package:app/ui/message/user_item_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class FollowListView extends StatefulWidget {
  final bool showFans;
  final bool showSend;
  final bool showLike;
  FollowListView({
    this.showFans = false,
    this.showSend = false,
    this.showLike = false,
  });
  @override
  _FollowListViewState createState() => _FollowListViewState();
}

class _FollowListViewState extends NetPageList<Map, FollowListView> {
  @override
  Future fetchPage(PageNum page) => Api.User.following(page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) => UserItemView(item,
    showLike: widget.showLike,
    showFans: widget.showFans,
    showSend: widget.showSend,
  );

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(height: 1, indent: 73, endIndent: 15),
    );
  }
}
