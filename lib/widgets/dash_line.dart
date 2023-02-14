import 'package:flutter/material.dart';

class DashLine extends StatelessWidget {
  final Color color;
  final double height;
  final List<double> step;

  const DashLine({
    this.color,
    this.height = 1,
    this.step = const [3, 2],
  });

  @override
  Widget build(BuildContext context) {
    final _color = color ?? Theme.of(context).dividerColor;

    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;

        return CustomPaint(
          painter: _DashPainter(_color, height, step[0], step[1]),
          size: Size(w, height),
        );
      },
    );
  }
}

class VerticalDashLine extends StatelessWidget {
  final Color color;
  final double width;
  final List<double> step;

  const VerticalDashLine({
    this.color,
    this.width = 1,
    this.step = const [3, 2],
  });

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: DashLine(height: width, step: step, color: color),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double step1;
  final double step2;
  final double strokeWidth;

  _DashPainter(this.color, this.strokeWidth, this.step1, this.step2);

  Paint _paint;

  Paint init() {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint ??= init();

    final w = size.width;

    final path = Path();

    double total = 0;
    bool flag = true;

    while (total < w) {
      final offs = w - total;

      double x;

      if (flag) {
        x = offs > step1 ? step1 : offs;

        path.relativeLineTo(x, 0);
      } else {
        x = offs > step2 ? step2 : offs;

        path.relativeMoveTo(x, 0);
      }

      total += x;
      flag = !flag;
    }

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.step1 != step1 || old.step2 != step2 || old.strokeWidth != strokeWidth;
}
