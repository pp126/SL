import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';

class IntroOverlay extends StatelessWidget {
  final circle = Container(
    decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
  );

  final rectangle = Container(
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(AppPalette.barrier, BlendMode.srcOut),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(top: 10, right: 106, width: 28, height: 28, child: circle),
                  Positioned(top: 58.5, left: 84, width: 28, height: 28, child: circle),
                  Positioned(top: 100, left: 12, right: 12, height: 200, child: rectangle),
                  Positioned(top: 320, left: 12, width: 220, height: 120, child: rectangle),
                  Positioned(right: 6, bottom: 0, width: 56, height: 56, child: circle),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          minimum: EdgeInsets.only(bottom: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 125,
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  child: Image.asset(IMG.$('room/intro/0'), scale: 3),
                  onTap: () => Bus.send(CMD.close_overlay, this),
                ),
              ),
              Positioned(
                top: 10,
                right: 140,
                child: Image.asset(IMG.$('room/intro/1'), scale: 3),
              ),
              Positioned(
                top: 60,
                left: 123,
                child: Image.asset(IMG.$('room/intro/2'), scale: 3),
              ),
              Positioned(
                top: 270,
                right: 16,
                child: Image.asset(IMG.$('room/intro/3'), scale: 3),
              ),
              Positioned(
                top: 360,
                left: 200,
                child: Image.asset(IMG.$('room/intro/4'), scale: 3),
              ),
              Positioned(
                right: 72,
                bottom: 18,
                child: Image.asset(IMG.$('room/intro/5'), scale: 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
