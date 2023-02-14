import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

import 'add_auction_page.dart';
import 'common/style.dart';

class AuctionHomeView extends StatelessWidget {
  final orderRx = Rx(Tuple2('无', true));
  final searchRx = RxString('');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          _SearchBar(searchRx),
          Style.divider,
          _OrderBar(orderRx),
          Divider(),
          Expanded(
            child: Style.useOrder(
              orderRx,
              (it) => Obx(() => _ListView(searchRx.value, it)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final RxString searchRx;

  _SearchBar(this.searchRx);

  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      child: Row(
        children: [
          Spacing.w16,
          Expanded(
            child: Container(
              height: 36,
              decoration: ShapeDecoration(shape: StadiumBorder(), color: AppPalette.divider),
              child: Row(
                children: [
                  Spacing.w16,
                  Image.asset(IMG.$('拍卖搜索'), scale: 2),
                  Spacing.w8,
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration.collapsed(hintText: '请输入物品名称'),
                      style: TextStyle(fontSize: 11, color: AppPalette.txtDark),
                    ),
                  ),
                  Spacing.w8,
                  Style.btn1(title: '搜索', width: 60, height: 32, onTap: () => searchRx.value = ctrl.text),
                  Spacing.w2,
                ],
              ),
            ),
          ),
          Spacing.w16,
          Style.btn2(title: '拍卖商品', onTap: AddAuctionPage.to),
          Spacing.w16,
        ],
      ),
    );
  }
}

class _OrderBar extends StatelessWidget {
  final Rx<Tuple2<String, bool>> orderRx;

  _OrderBar(this.orderRx);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 12, color: AppPalette.tips),
        child: Row(
          children: [
            Style.column(Text('商品')),
            Style.column(Style.orderView(orderRx, '单价')),
            Style.column(Style.orderView(orderRx, '价格')),
          ],
        ),
      ),
    );
  }
}

class _ListView extends StatefulWidget {
  final String search;
  final int orderType;

  _ListView(this.search, this.orderType) : super(key: Key('$search#$orderType'));

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends NetPageList<Map, _ListView> {
  @override
  BaseConfig initListConfig() => ListConfig(divider: Divider());

  @override
  Future fetchPage(PageNum page) => Api.Auction.list(widget.search, widget.orderType, page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return Style.itemView(
      item,
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Style.btn1(title: '一口价', onTap: () => doSub(item)), Spacing.w16],
      ),
    );
  }

  void doSub(Map item) async {
    final ts1 = TextStyle(fontSize: 13, color: AppPalette.txtDark);
    final ts2 = TextStyle(color: AppPalette.txtPrimary);

    final result = await Get.simpleDialog(
      content: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '是否确定以 '),
            TextSpan(text: '${item['giftTotalPrice']}', style: ts2),
            TextSpan(text: '珍珠', style: ts2),
            TextSpan(text: ' 购买\n'),
            TextSpan(text: item['giftName'], style: ts2),
            TextSpan(text: ' 商品!'),
          ],
        ),
        textAlign: TextAlign.center,
        style: ts1,
      ),
    );

    if (result == '确定') {
      simpleSub(
        Api.Auction.purchase(item['id']),
        callback: () => delItem(item),
      );
    }
  }
}
