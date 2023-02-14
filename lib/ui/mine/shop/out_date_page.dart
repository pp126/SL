import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class OutDateProductPage extends StatefulWidget {
  @override
  _OutDateProductPageState createState() => _OutDateProductPageState();
}

class _OutDateProductPageState extends State<OutDateProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '已过期',
      ),
      body: OutDateItem(),
    );
  }
}

class OutDateItem extends StatefulWidget {
  final ProductType type;
  OutDateItem({
    this.type = ProductType.car,
  });
  @override
  _OutDateItemState createState() => _OutDateItemState();
}

class _OutDateItemState extends NetPageList<Map,OutDateItem> {
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
        childAspectRatio: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
    );
  }
  @override
  List<Map> transform(data) {
    return super.transform(data['list']);
  }
  @override
  Future fetchPage(PageNum page) {
    var api;
    switch(widget.type){
      case ProductType.car:
        api = Api.User.userCarList(
            userId:(OAuthCtrl.obj.uid ?? '').toString(),
            page: page
        );
        break;
      case ProductType.head:
        api = Api.User.userHeadList(
            userId:(OAuthCtrl.obj.uid ?? '').toString(),
            page: page
        );
        break;
    }
    return api;
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return ProductItem(item);
  }
}
