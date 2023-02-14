import 'package:app/net/api.dart';
import 'package:app/ui/message/user_item_view.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

enum UserType {
  friend,///好友
  follow,///关注
}

class SendUserListView extends StatefulWidget {
  final UserType type;
  final productData;
  final ProductType productType;
  SendUserListView({
    this.type = UserType.follow,
    this.productType = ProductType.car,
    this.productData,
  });
  @override
  _SendUserListViewState createState() => _SendUserListViewState();
}

class _SendUserListViewState extends NetPageList<Map, SendUserListView> {
  @override
  Future fetchPage(PageNum page){
    var api;
    print(333);
    switch(widget.type){
      case UserType.friend:
        api = Api.User.friend();
        break;
      case UserType.follow:
        api = Api.User.following(page);
        break;
    }
    return api;
  }
  @override
  void onEnd() {
    // TODO: implement onEnd
    switch(widget.type){
      case UserType.friend:
        break;
      case UserType.follow:
        super.onEnd();
        break;
    }
  }
  @override
  Widget itemBuilder(BuildContext context, Map item, int index){
    return UserItemView(
      item,
      showSend: true,
      productData: widget.productData,
      productType: widget.productType,
    );
  }

  @override
  BaseConfig initListConfig() {
    return ListConfig(
      divider: Divider(height: 1, indent: 73, endIndent: 15),
    );
  }
}
