import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/ui/mine/shop/shop_item.dart';
import 'package:app/ui/mine/task/my_task_page.dart';
import 'package:flutter/material.dart';

class ExchangePage extends StatefulWidget {
  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: CoinItem(),
          ),
        ];
      },
      body: ShopItem(type:ProductType.giftExchange,),
    );
  }
}