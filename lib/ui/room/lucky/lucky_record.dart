import 'dart:ui' as ui;

import 'package:app/common/theme.dart';
import 'package:app/ui/common/money_icon.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/network_cache_image.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../tools.dart';

Widget $BoxView() {
  return Container(
    height: 116.4,
    width: 138.6,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: -16,
          width: 318,
          height: 135,
          child: Image.asset(IMG.$('宝箱_阴影'), scale: 3),
        ),
        Positioned(
          top: 0,
          height: 194,
          width: 231,
          child: Image.asset(IMG.$('宝箱'), scale: 3),
        ),
      ],
    ),
  );
}

Widget $Btn({
  String title,
  double width,
  double height,
  VoidCallback onTap,
  Color bg = AppPalette.primary,
  ShapeBorder shape = const StadiumBorder(),
  TextStyle textStyle = const TextStyle(fontSize: 14, color: Colors.white),
}) {
  return Material(
    color: bg,
    shape: shape,
    textStyle: textStyle,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: Text(title),
      ),
      onTap: onTap,
    ),
  );
}

class GiftDialog extends StatefulWidget {
  final int count;
  final List data;
  final VoidCallback oneMore;

  GiftDialog(this.count, this.data, this.oneMore);

  @override
  _GiftDialogState createState() => _GiftDialogState();

  static final decoration = [
    BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFCE7EFF), Color(0xFF7C66FF)],
      ),
    ),
    BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Color(0xff252142),
    ),
  ];
}

class _GiftDialogState extends State<GiftDialog> {
  static final _img = getAssetImage(
    IMG.$('抽奖特效背景'),
    width: Get.width ~/ 1.5,
    height: Get.width ~/ 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: FutureBuilder(
        future: _img,
        builder: (_, data) {
          return !data.hasData //
              ? SizedBox.shrink()
              : Stack(
                  children: [
                    CustomPaint(
                      painter: LuckyPainter(data.data, widget.data.length, 3),
                      isComplex: true,
                      willChange: true,
                      child: Material(
                        type: MaterialType.transparency,
                        child: GridLayout(
                          crossAxisCount: 3,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 8 / 8,
                          padding: EdgeInsets.all(0),
                          children: [
                            for (final it in widget.data) createItem(it)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 50,
                      right: 50,
                      bottom: 44,
                      child: $Btn(
                        title: '再来一次',
                        height: 40,
                        bg: Color(0xff7C66FF),
                        textStyle:
                            TextStyle(fontSize: 14, color: AppPalette.txtWhite),
                        onTap: () {
                          Get.back();
                          widget.oneMore();
                        },
                      ),
                    ),
                    Positioned(
                      left: 50,
                      right: 50,
                      bottom: 100,
                      child: $Btn(
                        title: count(widget.data),
                        height: 40,
                        bg: Color(0x00000000),
                        textStyle:
                            TextStyle(fontSize: 18, color: AppPalette.txtWhite),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  String count(List data) {
    var totalPrice = 0;
    for (final it in widget.data) {
      totalPrice += it['goldPrice'];
    }
    return '总价值：${totalPrice}';
  }

  Widget createItem(Map data) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 78,
              height: 95,
              decoration: GiftDialog.decoration[0],
              padding: EdgeInsets.all(2),
              child: Container(
                decoration: GiftDialog.decoration[1],
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(child: NetImage(data['picUrl'])),
                    Spacing.h2,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MoneyIcon(size: 14),
                        Text(
                          '${data['goldPrice']}',
                          style:
                              TextStyle(fontSize: 10, color: Color(0xffFFCB2F)),
                        ),
                      ],
                    ),
                    Spacing.h2,
                    Text(
                      '${data['giftName']} x${data['giftNum']}',
                      style:
                          TextStyle(fontSize: 10, color: AppPalette.txtWhite),
                    ),
                    Spacing.h4,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  judge(int index, List data) {
    return index <= data.length ? index : data.length;
  }

  static Future<ui.Image> getAssetImage(String asset,
      {int width, int height}) async {
    final data = await rootBundle.load(asset);

    final code = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);

    final fi = await code.getNextFrame();

    return fi.image;
  }
}

class LuckyPainter extends CustomPainter {
  Paint selfPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.butt
    ..strokeWidth = 30.0;
  ui.Image image;
  int count;
  int crossAxisCount;

  LuckyPainter(this.image, this.count, this.crossAxisCount);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    double size = image.width.toDouble();
    double rowd = size / 2.6;
    double colnmd = size / 3.1;

    for (int i = 0, j = (count / crossAxisCount).ceil(); i < j; i++) {
      double colnmDifference = (i + 1) * colnmd;
      if (i > 0) {
        colnmDifference += 40;
      }
      for (int a = i * crossAxisCount,
              z = judge(((i + 1) * crossAxisCount), count);
          a < z;
          a++) {
        int rowIndex = a - i * crossAxisCount;
        double rowDifference = (rowIndex + 1) * rowd;
        if (rowIndex == 0) {
          rowDifference += -25;
        } else if (rowIndex == 2) {
          rowDifference += 25;
        }
        canvas.drawImage(
            image,
            Offset(rowIndex * size - rowDifference, i * size - colnmDifference),
            selfPaint);
      }
    }
  }

  judge(int index, int length) {
    return index <= length ? index : length;
  }

  @override
  bool shouldRepaint(LuckyPainter oldDelegate) {
    return false;
  }
}
