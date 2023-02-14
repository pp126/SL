import 'package:app/common/theme.dart';
import 'package:app/event/gift_event.dart';
import 'package:app/event/pay_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/ui/mine/send/send_user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';

enum ProductType {
  car,

  ///座驾
  head,

  ///头饰
  giftExchange,

  ///任务道具
}

class ProductItem extends StatelessWidget {
  final data;
  final ProductType type;
  final bool selected;
  final VoidCallback clickCallBack;

  ProductItem(
    this.data, {
    this.type,
    this.selected = false,
    this.clickCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final item = {
      ProductType.car: [
        'vggUrl',
        'picUrl',
        'carName',
        '',
      ],
      ProductType.head: [
        'vggUrl',
        'picUrl',
        'headwearName',
        '',
      ],
      ProductType.giftExchange: ['vggUrl', 'giftUrl', 'giftName', 'userGiftPurseNum'],
    }[type];
    var count = xMapStr(data, item[3], defaultStr: 0);

    ///背包礼物会有多个
    bool isCar = type == ProductType.car;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          selected ? Color(0xffC69FFF) : AppPalette.background,
          selected ? Color(0xff7C66FF) : AppPalette.background,
        ]),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                  selected ? Color(0xffA183FF) : Colors.white,
                  selected ? Color(0xff7C66FF) : Colors.white,
                ]),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              width: double.infinity,
              height: double.infinity,
              child: InkWell(
                onTap: isCar
                    ? () async {
                        GiftEffectCtrl.obj.play(xMapStr(data, item[0]));

                        if (clickCallBack != null) {
                          clickCallBack();
                        }
                      }
                    : null,
                child: NetImage(
                  xMapStr(
                    data,
                    item[1],
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Spacing.h4,
          Text(
            xMapStr(data, item[2]),
            style: TextStyle(fontSize: 14, color: selected ? Colors.white : AppPalette.tips),
          ),
          Spacing.h4,
          if (count > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                '当前拥有量：$count',
                style: TextStyle(fontSize: 14, color: selected ? Colors.white : AppPalette.tips),
              ),
            ),
          PriceItem(
            data,
            type: type,
            selected: selected,
          ),
        ],
      ),
    );
  }
}

class PriceItem extends StatelessWidget {
  final data;
  final ProductType type;
  final bool selected;

  PriceItem(
    this.data, {
    this.type,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      MoneyIcon(size: 16, type: data['giftType'] == 5 ? '珊瑚' : '海星'),
      Spacing.w4,
      Text(
        xMapStr(data, 'goldPrice').toString(),
        style: TextStyle(fontSize: 14, color: selected ? Colors.white : AppPalette.primary),
      ),
    ]);
  }
}

class BuyProductItem extends StatelessWidget {
  final data;
  final ProductType type;

  BuyProductItem(
    this.data, {
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PriceItem(
            data,
            type: type,
          ),
          _buyItem(),
        ],
      ),
    );
  }

  Widget _buyItem() {
    double width = 74;
    double height = 34;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AppTextButton(
          width: width,
          height: height,
          bgColor: AppPalette.txtWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          title: Text(
            '赠送',
            style: TextStyle(fontSize: 14, color: AppPalette.primary),
          ),
          onPress: () {
            Get.to(SendUserPage(
              productData: data,
              type: type,
            ));
          },
        ),
        Spacing.w2,
        AppTextButton(
          width: width,
          height: height,
          bgColor: AppPalette.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            bottomLeft: Radius.circular(2),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          title: Text(
            '购买',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          onPress: doBuy,
        ),
      ],
    );
  }

  //购买座驾、头饰
  doBuy() {
    var api;
    switch (type) {
      case ProductType.car:
        api = Api.User.buyCar(
          carId: xMapStr(data, 'carId').toString(),
        );
        break;
      case ProductType.head:
        api = Api.User.buyHead(
          headwearId: xMapStr(data, 'headwearId').toString(),
        );
        break;
      case ProductType.giftExchange:
        api = Api.Gift.exchangeGift(
          giftId: xMapStr(data, 'giftId').toString(),
        );
        break;
    }

    simpleSub(api, msg: '购买成功', callback: () {
      switch (type) {
        case ProductType.car:
          break;
        case ProductType.head:
          break;
        case ProductType.giftExchange:
          Bus.fire(CoinChangeEvent());
          Bus.fire(PackageGiftChangeEvent());
          break;
      }
    });
  }
}

class SetProductItem extends StatelessWidget {
  final data;
  final ProductType type;
  final VoidCallback completeBack;

  SetProductItem(
    this.data, {
    this.type,
    this.completeBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          _setItem(),
        ],
      ),
    );
  }

  Widget _setItem() {
    double width = 84;
    double height = 34;
    return GetX<OAuthCtrl>(builder: (it) {
      String picUrl = xMapStr(data, 'picUrl');
      bool isSet = false;
      var userInfo = it.info.value;
      if (type == ProductType.car) {
        isSet = xMapStr(userInfo, 'carUrl', defaultStr: '') == picUrl;
      } else if (type == ProductType.head) {
        isSet = xMapStr(userInfo, 'headwearUrl', defaultStr: '') == picUrl;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AppTextButton(
            width: width,
            height: height,
            bgColor: AppPalette.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            title: Text(
              isSet ? '取消设置' : '设置',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            onPress: isSet ? doNotSet : doSet,
          ),
        ],
      );
    });
  }

  //设置座驾、头饰
  doSet() {
    switch (type) {
      case ProductType.car:
        {
          String carId = xMapStr(data, 'carId').toString();
          String carUrl = xMapStr(data, 'picUrl');
          String carName = xMapStr(data, 'carName');
          simpleSub(
              Api.User.setCar(
                carId: carId,
              ),
              msg: '设置成功', callback: () {
            OAuthCtrl.obj.updateUserInfo({'carUrl': carUrl, 'carName': carName});
            if (completeBack != null) {
              completeBack();
            }
          });
        }
        break;
      case ProductType.head:
        {
          String headwearId = xMapStr(data, 'headwearId').toString();
          String headwearUrl = xMapStr(data, 'picUrl');
          String headwearName = xMapStr(data, 'headwearName');
          simpleSub(
              Api.User.setHead(
                headwearId: headwearId,
              ),
              msg: '设置成功', callback: () {
            OAuthCtrl.obj.updateUserInfo({'headwearUrl': headwearUrl, 'headwearName': headwearName});
            if (completeBack != null) {
              completeBack();
            }
          });
        }
        break;
    }
  }

  //取消设置座驾、头饰
  doNotSet() {
    switch (type) {
      case ProductType.car:
        {
          simpleSub(
              Api.User.setCar(
                carId: '-1',
              ),
              msg: '设置成功', callback: () {
            OAuthCtrl.obj.updateUserInfo({'carUrl': '', 'carName': ''});
            if (completeBack != null) {
              completeBack();
            }
          });
        }
        break;
      case ProductType.head:
        {
          simpleSub(
              Api.User.setHead(
                headwearId: '-1',
              ),
              msg: '设置成功', callback: () {
            OAuthCtrl.obj.updateUserInfo({'headwearUrl': '', 'headwearName': ''});
            if (completeBack != null) {
              completeBack();
            }
          });
        }
        break;
    }
  }
}
