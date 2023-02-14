import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';

import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

class ShopItem extends StatefulWidget {
  final ProductType type;
  ShopItem({
    this.type,
  });
  @override
  _ShopItemState createState() => _ShopItemState();
}

class _ShopItemState extends NetPageList<Map,ShopItem> {

  var selectItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  BaseConfig initListConfig() {
    return GridConfig(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 164/174,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
    );
  }

  @override
  Future fetchPage(PageNum page) {
    var api;
    switch(widget.type){
      case ProductType.car:
        api = Api.User.shopCarList(
            userId:(OAuthCtrl.obj.uid ?? '').toString(),
            page: page
        );
        break;
      case ProductType.head:
        api = Api.User.shopHeadList(
            userId:(OAuthCtrl.obj.uid ?? '').toString(),
            page: page
        );
        break;
      case ProductType.giftExchange:
        api = Api.Gift.freeGiftList(
            page: page
        );
        break;
    }
    return api;
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => Column(
    children: [
      Expanded(
        child: child,
      ),
      _buildInputItem(),
    ],
  );

  _buildInputItem() {
    return selectItem != null ? BuyProductItem(
      selectItem,
      type: widget.type,
    ) : SizedBox();
  }


  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return GestureDetector(
      onTap: (){
        onSelectTap(item);
      },
      child: ProductItem(
        item,
        type: widget.type,
        selected: selectItem == item,
        clickCallBack: (){
          onSelectTap(item);
        },
      ),
    );
  }
  onSelectTap(Map item){
    setState(() {
      selectItem = item;
    });
  }
}