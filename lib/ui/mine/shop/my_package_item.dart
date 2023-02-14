import 'package:app/common/theme.dart';
import 'package:app/event/gift_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/send/send_user_page.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:flutter/material.dart';

class MyPackageItem extends StatefulWidget {
  final ProductType type;

  MyPackageItem({
    this.type,
  });

  @override
  _MyPackageItemState createState() => _MyPackageItemState();
}

class _MyPackageItemState extends NetPageList<Map, MyPackageItem> {
  var selectItem;

  @override
  void initState() {
    super.initState();
    Bus.on<PackageGiftChangeEvent>((data) {
      doRefresh();
    });
  }

  @override
  List<Map> transform(data) {
    if (data is Map) {
      return super.transform(data['list']);
    } else {
      return super.transform(data);
    }
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
  Future fetchPage(PageNum page) {
    var api;
    switch (widget.type) {
      case ProductType.car:
        api = Api.User.userCarList(userId: (OAuthCtrl.obj.uid ?? '').toString(), page: page);
        break;
      case ProductType.head:
        api = Api.User.userHeadList(userId: (OAuthCtrl.obj.uid ?? '').toString(), page: page);
        break;
      case ProductType.giftExchange:
        api = Api.Gift.packageGiftList(page: page);
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
    final item = {
      ProductType.car: [setItem(), jump()],
      ProductType.head: [setItem(), jump()],
      ProductType.giftExchange: [jump(), SizedBox()],
    }[widget.type];
    return selectItem != null ? item[0] : item[1];
  }

  setItem() {
    return SetProductItem(
      selectItem,
      type: widget.type,
      completeBack: () {
        setState(() {
          selectItem = null;
        });
      },
    );
  }

  jump() {
    final item = {
      ProductType.car: [
        '去商城逛逛吧',
        () {
          showToast('开发中，敬请期待');
        },
      ],
      ProductType.head: [
        '去商城逛逛吧',
        () {
          showToast('开发中，敬请期待');
        },
      ],
      ProductType.giftExchange: [
        '去送礼物',
        () {
          Get.to(SendUserPage(
            productData: selectItem,
            type: widget.type,
          ));
        },
      ],
    }[widget.type];
    return Text(
      item[0],
      style: TextStyle(color: AppPalette.primary, fontSize: 14),
    ).toBtn(
      40,
      AppPalette.txtWhite,
      margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
      onTap: item[1],
    );
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return GestureDetector(
      onTap: () {
        onSelectTap(item);
      },
      child: ProductItem(
        item,
        type: widget.type,
        selected: selectItem == item,
        clickCallBack: () {
          onSelectTap(item);
        },
      ),
    );
  }

  onSelectTap(Map item) {
    setState(() {
      selectItem = item;
    });
  }
}
