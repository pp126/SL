import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/widgets.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class Style {
  Style._();

  static Divider divider = Divider(height: 10, thickness: 10, color: AppPalette.background);

  static Widget orderView(Rx<Tuple2<String, bool>> rx, String title) {
    return Obx(() {
      final order = rx.value;

      final isShow = order.item1 == title;

      return InkWell(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              isShow
                  ? Icon(
                      order.item2 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: AppPalette.dark,
                      size: 16,
                    )
                  : SizedBox.fromSize(size: Size.square(16)),
            ],
          ),
        ),
        onTap: () {
          rx.value = isShow //
              ? order.withItem2(!order.item2)
              : Tuple2(title, true);
        },
      );
    });
  }

  static Widget column(Widget child) {
    return Container(width: 88, alignment: Alignment.center, child: child);
  }

  static Widget btn1({String title, double width = 80, double height = 36, VoidCallback onTap}) {
    return Container(
      width: width,
      height: height,
      child: Material(
        type: MaterialType.transparency,
        shape: StadiumBorder(side: BorderSide(color: AppPalette.primary)),
        clipBehavior: Clip.antiAlias,
        textStyle: TextStyle(fontSize: 12, color: AppPalette.primary),
        child: InkWell(
          child: Center(child: Text(title)),
          onTap: onTap,
        ),
      ),
    );
  }

  static Widget btn2({String title, VoidCallback onTap}) {
    return Container(
      width: 94,
      height: 36,
      child: Material(
        type: MaterialType.transparency,
        textStyle: TextStyle(fontSize: 13, color: Colors.white),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            gradient: LinearGradient(
              end: Alignment.topRight,
              begin: Alignment.bottomLeft,
              colors: [AppPalette.primary, Color(0xFFA366FF)],
            ),
          ),
          child: InkWell(
            child: Center(child: Text(title)),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  static Widget btn3({String title, Color color, VoidCallback onTap}) {
    return Container(
      width: 36,
      height: 36,
      child: Material(
        type: MaterialType.transparency,
        textStyle: TextStyle(fontSize: 13, color: color, fontWeight: fw$SemiBold),
        child: InkWell(
          child: Center(child: Text(title)),
          onTap: onTap,
        ),
      ),
    );
  }

  static Widget itemView(Map item, Widget extView) {
    final format = NumberFormat.percentPattern();

    return SizedBox(
      height: 74,
      child: Row(
        children: [
          Style.column(
            Stack(
              // overflow: Overflow.visible,
              children: [
                NetImage(item['giftPic'], width: 44, height: 44),
                Positioned(
                  top: -4,
                  left: 32,
                  child: BorderedText(
                    strokeWidth: 2,
                    strokeColor: AppPalette.pink,
                    child: Text(
                      'X${item['giftNum']}',
                      style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: fw$SemiBold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Style.column(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['giftName'],
                  style: TextStyle(fontSize: 12, color: AppPalette.txtDark),
                ),
                Spacing.w32,
                Text(
                  '单价:${item['giftPrice']}',
                  style: TextStyle(fontSize: 11, color: AppPalette.tips),
                ),
              ],
            ),
          ),
          Style.column(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyIcon(type: '珍珠', size: 20),
                    Text(
                      '${item['giftTotalPrice']}',
                      style: TextStyle(fontSize: 14, color: AppPalette.txtDark, fontWeight: fw$SemiBold),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '折扣:'),
                      TextSpan(
                        text: format.format(item['giftPercentage']),
                        style: TextStyle(color: Color(0xFFFF6666)),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 11, color: AppPalette.tips),
                ),
              ],
            ),
          ),
          Expanded(child: extView),
        ],
      ),
    );
  }

  static Widget useOrder(Rx<Tuple2<String, bool>> rx, Widget Function(int) builder) {
    return Obx(() {
      int orderType = 0;

      final order = rx.value;

      switch (order?.item1) {
        case '单价':
          orderType = order.item2 ? 1 : 2;
          break;
        case '价格':
          orderType = order.item2 ? 3 : 4;
          break;
      }

      return builder(orderType);
    });
  }
}
