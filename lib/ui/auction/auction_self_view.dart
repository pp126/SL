import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/auction/add_auction_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tuple/tuple.dart';

import 'common/style.dart';

class AuctionSelfView extends StatefulWidget {
  @override
  _AuctionSelfViewState createState() => _AuctionSelfViewState();
}

class _AuctionSelfViewState extends State<AuctionSelfView> {
  final tabs = {'已上架': 1, '已下架': 2, '交易成功': 3, '已取消': 4};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: DefaultTabController(
        length: tabs.length,
        child: Column(
          children: [
            Divider(),
            xAppBar$TabBar(
              tabs.keys.map((it) => Tab(text: it)).toList(growable: false),
              isScrollable: false,
            ),
            Expanded(
              child: TabBarView(
                children: tabs.values //
                    .map((it) => DelayView(_PageView(it)))
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final int type;

  _PageView(this.type);

  final orderRx = Rx(Tuple2('无', true));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Style.divider,
        _OrderBar(orderRx, type),
        Divider(),
        Expanded(
          child: Style.useOrder(
            orderRx,
            (it) => _ListView(type, it),
          ),
        ),
      ],
    );
  }
}

class _OrderBar extends StatelessWidget {
  final Rx<Tuple2<String, bool>> orderRx;
  final int type;

  _OrderBar(this.orderRx, this.type);

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
            Expanded(child: Center(child: statusView())),
          ],
        ),
      ),
    );
  }

  Widget statusView() {
    switch (type) {
      case 1:
      case 2:
        return Text('操作');
      case 3:
        return Text('交易时间');
      case 4:
        return Text('过期时间');
      default:
        assert(false);

        return SizedBox.shrink();
    }
  }
}

class _ListView extends StatefulWidget {
  final int type;
  final int orderType;

  _ListView(this.type, this.orderType) : super(key: Key('$type#$orderType'));

  @override
  _ListViewState createState() => _ListViewState();
}

class _ListViewState extends NetPageList<Map, _ListView> {
  final timeTs = TextStyle(fontSize: 11, color: AppPalette.tips);

  @override
  BaseConfig initListConfig() => ListConfig(divider: Divider());

  @override
  Future fetchPage(PageNum page) => Api.Auction.listMyAuction(widget.type, widget.orderType, page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    Widget child = Style.itemView(item, statusView(item));

    if (widget.type != 1) {
      child = Slidable(
        // todo
        // startActionPane: ActionPane(motion: null,),
        child: child,
      );
    }

    return child;
  }

  Widget statusView(Map item) {
    switch (widget.type) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Style.btn3(
              title: '下架',
              color: AppPalette.pink,
              onTap: () => onItemClick(item, '下架'),
            ),
          ],
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Style.btn3(
              title: '上架',
              color: AppPalette.pink,
              onTap: () => onItemClick(item, '上架'),
            ),
            Style.btn3(
              title: '编辑',
              color: AppPalette.txtPrimary,
              onTap: () => onItemClick(item, '编辑'),
            ),
          ],
        );
      default:
        return Center(child: Text(TimeUtils.getNewsTimeStr(item['updateTime']), style: timeTs));
    }
  }

  void onItemClick(Map item, String action) {
    Future api;

    switch (action) {
      case '上架':
        api = Api.Auction.onShelf(item['id']);
        break;
      case '下架':
        api = Api.Auction.offShelf(item['id']);
        break;
      case '删除':
        api = Api.Auction.delRecord(item['id']);
        break;
      case '编辑':
        AddAuctionPage.to(item);
        return;
    }

    simpleSub(
      api,
      callback: () => delItem(item),
    );
  }
}
