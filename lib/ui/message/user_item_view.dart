import 'package:app/common/theme.dart';
import 'package:app/event/gift_event.dart';
import 'package:app/event/pay_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/message/chat/chat_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/shop/product_item.dart';
import 'package:app/ui/room/room_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserItemView extends StatefulWidget {
  final Map data;
  final bool showFans;
  final bool showSend;
  final bool showLike;

  ///赠送礼物
  final ProductType productType;
  final productData;

  UserItemView(
    this.data, {
    this.showFans = false,
    this.showSend = false,
    this.showLike = false,
    this.productData,
    this.productType,
  });

  @override
  _UserItemViewState createState() => _UserItemViewState();
}

class _UserItemViewState extends State<UserItemView> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            RectAvatarView(size: 48, url: widget.data['avatar'], uid: widget.data['uid']),
            Spacing.w10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.data['nick'] ?? '',
                        style: TextStyle(fontSize: 14, color: AppPalette.dark, fontWeight: fw$SemiBold),
                      ),
                      Spacing.w8,
                      if (!widget.showFans) SvgPicture.asset(SVG.$('mine/性别_${widget.data['gender']}')),
                    ],
                  ),
                  Spacing.h10,
                  UidBox(data: widget.data, hasBG: false, color: AppPalette.tips),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.showFans) btn$Follow(),
                if (widget.showLike) btn$Like(),
                if (widget.showSend) btn$Send(),
              ],
            )
          ],
        ),
      ),
      onTap: () => onItemClick('找ta聊聊'),
    );
  }

  doSend() {
    var api;
    switch (widget.productType) {
      case ProductType.car:
        api = Api.User.sendCar(
          targetUid: widget.data['uid'].toString(),
          carId: xMapStr(widget.productData, 'carId').toString(),
        );
        break;
      case ProductType.head:
        api = Api.User.sendHead(
          targetUid: widget.data['uid'].toString(),
          headwearId: xMapStr(widget.productData, 'headwearId').toString(),
        );
        break;
      case ProductType.giftExchange:
        api = Api.Gift.sendPackageGift(
          targetUid: widget.data['uid'].toString(),
          giftId: xMapStr(widget.productData, 'giftId').toString(),
        );
        break;
    }

    simpleSub(
      api,
      msg: '赠送成功',
      callback: () {
        Get.back();
        switch (widget.productType) {
          case ProductType.car:
            break;
          case ProductType.head:
            break;
          case ProductType.giftExchange:
            Bus.fire(CoinChangeEvent());
            Bus.fire(PackageGiftChangeEvent());
            break;
        }
      },
    );
  }

  Widget btn$Like() {
    Widget child = Container(
      width: 70,
      height: 24,
      alignment: Alignment.center,
      child: Text(
        widget.data['isLike'] ?? true ? '已关注' : '关注',
        style: TextStyle(fontSize: 10, color: AppPalette.primary, height: 1),
      ),
    );

    child = InkWell(
      child: child,
      onTap: () => onItemClick('关注'),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: AppPalette.txtWhite,
        shape: StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget btn$Follow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: AppPalette.pink,
        shape: StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: Container(
            width: 70,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '去找ta',
              style: TextStyle(fontSize: 10, color: Colors.white, height: 1),
            ),
          ),
          onTap: () => onItemClick('去找ta'),
        ),
      ),
    );
  }

  Widget btn$Send() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: AppPalette.txtWhite,
        shape: StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: Container(
            width: 70,
            height: 24,
            alignment: Alignment.center,
            child: Text(
              '赠送',
              style: TextStyle(fontSize: 10, color: AppPalette.primary, height: 1),
            ),
          ),
          onTap: () => onItemClick('赠送'),
        ),
      ),
    );
  }

  void onItemClick(String title) async {
    final uid = widget.data['uid'];

    switch (title) {
      case '找ta聊聊':
        ChatPage.to(widget.data['nick'], widget.data['avatar'], uid);
        break;
      case '去找ta':
        final room = widget.data['userInRoom'];

        if (room == null) {
          showToast('对方不在房间内');
        } else {
          RoomPage.to(room['uid']);
        }
        break;
      case '关注':
        onFollowTap();
        break;
      case '赠送':
        doSend();
        break;
    }
  }

  ///关注用户
  onFollowTap() {
    final isLike = widget.data['isLike'] ?? true;

    simpleSub(
      Api.Home.followUser(likedUid: widget.data['uid'], isFollow: isLike),
      msg: isLike ? '取消关注' : '关注成功',
      callback: () {
        OAuthCtrl.obj.doRefresh();

        setState(() => widget.data['isLike'] = !isLike);
      },
    );
  }
}
