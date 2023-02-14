import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/store/gift_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_swiper_pagination.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

class AddAuctionPage extends StatefulWidget {
  final Map editVal;

  AddAuctionPage._(this.editVal);

  static void to([Map editVal]) {
    Get.to(
      AddAuctionPage._(editVal),
      binding: BindingsBuilder.put(() => PackageGiftCtrl()),
    );
  }

  @override
  _AddAuctionPageState createState() => _AddAuctionPageState();
}

class _AddAuctionPageState extends State<AddAuctionPage> {
  static const _x = 0.8;

  final itemRx = Rx<_GiftInfo>(null);
  final amountRx = Rx(Tuple2(_x, 0));
  final inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    final editVal = widget.editVal;

    if (editVal != null) {
      itemRx.value = _GiftInfo.fromEditVal(editVal);
      amountRx.value = Tuple2(editVal['giftPercentage'], editVal['giftNum']);

      inputCtrl.text = '${editVal['giftNum']}';
    }

    ever(itemRx, (_GiftInfo it) {
      if (it == null) {
        amountRx.value = Tuple2(_x, 0);

        return;
      }

      hideKeyboard();

      amountRx.value = Tuple2(_x, it.purseNum);
      inputCtrl.text = '${it.purseNum}';
    });

    inputCtrl.addListener(() {
      final num = int.tryParse(inputCtrl.text) ?? 0;

      amountRx.value = amountRx.value.withItem2(num);
    });
  }

  @override
  void dispose() {
    inputCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: xAppBar('拍卖商品', bgColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(),
            _GiftView(itemRx),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  $Title(
                    '商品单价',
                    Row(
                      children: [
                        Expanded(flex: 105, child: $PercentView()),
                        Spacing.w16,
                        Expanded(flex: 165, child: $UnivalentView()),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    padding: EdgeInsets.only(left: 64, top: 6),
                    child: Text(
                      '请选择商品单价，价格为原价的80%~85%',
                      style: TextStyle(fontSize: 10, color: AppPalette.tips),
                    ),
                  ),
                  $Title(
                    '商品数量',
                    $InputWrap(
                      TextFormField(
                        controller: inputCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration.collapsed(hintText: '请输入数量'),
                        style:
                            TextStyle(fontSize: 13, color: AppPalette.txtDark),
                      ),
                    ),
                  ),
                  Spacing.h20,
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '注：1、拍卖行24小时内无人拍卖，系统自动将物品返回背包；\n'),
                          TextSpan(text: '\u3000\u30002、商品拍卖成功，系统收取千分之6手续费；'),
                        ],
                      ),
                      style: TextStyle(fontSize: 11, color: AppPalette.tips),
                    ),
                  ),
                  Spacing.h16,
                  IntrinsicWidth(
                    child: Container(
                      height: 30,
                      decoration: ShapeDecoration(
                        color: AppPalette.primary.withOpacity(0.1),
                        shape: StadiumBorder(),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      child: Obx(() {
                        final item = itemRx.value;
                        final amount = amountRx.value;
                        final num = amount.item2;

                        final ts1 = TextStyle(
                            fontSize: 11,
                            color: AppPalette.txtDark,
                            fontWeight: fw$SemiBold);
                        final ts2 = TextStyle(color: AppPalette.primary);

                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '商品 - '),
                              if (item != null)
                                TextSpan(
                                    text: '${item.name}($num)个', style: ts2),
                              TextSpan(text: '，总价值：'),
                              WidgetSpan(
                                child: MoneyIcon(type: '珍珠', size: 20),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              TextSpan(
                                  text: (univalent * num).toStringAsFixed(2),
                                  style: ts2),
                              TextSpan(text: '珍珠'),
                            ],
                          ),
                          style: ts1,
                        );
                      }),
                    ),
                  ),
                  Spacing.h10,
                  AppTextButton(
                    width: double.infinity,
                    height: 48,
                    bgColor: AppPalette.primary,
                    borderRadius: BorderRadius.circular(999),
                    title: Text(
                      '一键拍卖',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    onPress: doSub,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget $Title(String title, Widget child) {
    return Container(
      height: 40,
      child: Row(
        children: [
          Container(
            width: 64,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 13,
                  color: AppPalette.txtDark,
                  fontWeight: fw$SemiBold),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget $InputWrap(Widget child) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget $PercentView() {
    final format = NumberFormat.percentPattern();
    final data = List.generate(6, (index) => (80 + index) / 100);

    final ts = TextStyle(
      fontSize: 13,
      color: AppPalette.primary,
      fontWeight: fw$SemiBold,
    );

    final items = data
        .map(
          (it) => DropdownMenuItem(
            value: it,
            child: Center(child: Text(format.format(it))),
          ),
        )
        .toList(growable: false);

    return $InputWrap(
      Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: ObxValue<Rx<Tuple2<double, int>>>(
          (rx) {
            final initial = rx.value.item1;

            return DropdownButton<double>(
              style: ts,
              value: data.contains(initial) ? initial : null,
              underline: SizedBox.shrink(),
              items: items,
              onChanged: (it) {
                final item = itemRx.value;
                if (item == null) return;

                rx.value = rx.value.withItem1(it);
              },
            );
          },
          amountRx,
        ),
      ),
    );
  }

  Widget $UnivalentView() {
    return $InputWrap(
      Row(
        children: [
          MoneyIcon(type: '珍珠', size: 20),
          Spacing.w4,
          ObxValue(
            (it) {
              return Text(
                univalent.toStringAsFixed(2),
                style: TextStyle(fontSize: 13, color: AppPalette.primary),
              );
            },
            amountRx,
          ),
        ],
      ),
    );
  }

  double get univalent {
    final item = itemRx.value;

    if (item == null) return 0;

    return double.parse((amountRx.value.item1 * item.price).toStringAsFixed(2));
  }

  void doSub() async {
    final item = itemRx.value;
    final amount = amountRx.value;

    final percent = amount.item1;
    final num = amount.item2;

    if (item == null) {
      showToast('请选择拍卖礼物');

      return;
    }

    if (num == null || num <= 0) {
      showToast('请设置正确的礼物数量');

      return;
    }

    simpleSub(
      Api.Auction.shelf(item.id, num, percent),
      callback: () {
        // itemRx.nil();
        itemRx.value = null;

        Get.find<PackageGiftCtrl>().doRefresh();
      },
    );
  }
}

class _GiftView extends StatelessWidget {
  final Rx<_GiftInfo> itemRx;

  _GiftView(this.itemRx);

  final crossAxisCount = 4;
  final _colors = {
    true: Tuple4(
      BoxDecoration(
        gradient: LinearGradient(
          end: Alignment.topRight,
          begin: Alignment.bottomLeft,
          colors: [AppPalette.primary, Color(0xFFA366FF)],
        ),
      ),
      TextStyle(color: Colors.white),
      TextStyle(color: Colors.white, fontSize: 10),
      TextStyle(color: Colors.white, fontWeight: fw$SemiBold),
    ),
    false: Tuple4(
      BoxDecoration(color: AppPalette.divider),
      TextStyle(color: AppPalette.txtDark),
      TextStyle(color: AppPalette.tips, fontSize: 10),
      TextStyle(color: AppPalette.primary, fontWeight: fw$SemiBold),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PackageGiftCtrl>(
      builder: (it) {
        final data =
            partition(it.value, 3 * crossAxisCount).toList(growable: false);

        return FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
            color: Colors.white,
            height: 405,
            width: 375,
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Swiper(
              loop: false,
              autoplay: false,
              itemCount: data.length,
              itemBuilder: (_, i) {
                return GridLayout(
                  children: data[i].map(itemBuild).toList(growable: false),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 79 / 115,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                );
              },
              pagination: SwiperPagination(
                alignment: Alignment.bottomCenter,
                builder: APPDotSwiperPaginationBuilder(),
                margin: EdgeInsets.only(bottom: 10),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget itemBuild(data) {
    final img = NetImage(data['giftUrl'], width: 44, height: 44);

    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),
      textStyle: TextStyle(fontSize: 11, color: Colors.white),
      child: ObxValue<Rx<_GiftInfo>>(
        (it) {
          final selected = it.value != null && it.value.id == data['giftId'];
          final color = _colors[selected];

          Widget child = Column(
            children: [
              Spacing.h8,
              img,
              Spacing.h8,
              Text('${data['giftName']}', style: color.item2),
              Spacing.exp,
              Text('拥有:${data['userGiftPurseNum']}',
                  softWrap: false, style: color.item3),
              Spacing.exp,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoneyIcon(type: '珍珠', size: 13),
                  Spacing.w4,
                  Text('${data['goldPrice']}', style: color.item4),
                ],
              ),
              Spacing.h6,
            ],
          );

          child = DecoratedBox(
            decoration: color.item1,
            child: child,
          );

          if (!selected) {
            child = InkWell(
              child: child,
              onTap: () => it.value = _GiftInfo.fromSelectVal(data),
            );
          }

          return child;
        },
        itemRx,
      ),
    );
  }
}

class _GiftInfo {
  final int id;
  final String name;
  final int price;
  final int purseNum;

  _GiftInfo._({this.id, this.name, this.price, this.purseNum});

  factory _GiftInfo.fromSelectVal(data) {
    return _GiftInfo._(
      id: data['giftId'],
      name: data['giftName'],
      price: data['goldPrice'],
      purseNum: data['userGiftPurseNum'],
    );
  }

  factory _GiftInfo.fromEditVal(data) {
    return _GiftInfo._(
      id: data['giftId'],
      name: data['giftName'],
      price: data['originalPrice'],
      purseNum: data['giftNum'],
    );
  }
}
