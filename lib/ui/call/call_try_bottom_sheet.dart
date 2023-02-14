import 'package:app/common/theme.dart';
import 'package:app/store/call_overlay_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/common/svga_icon.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';

class CallTryBottomSheet extends StatelessWidget {
  CallTryBottomSheet._();

  static to() => Get.showBottomSheet(CallTryBottomSheet._());

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '语音通话',
              style: TextStyle(fontSize: 16, color: AppPalette.txtDark, fontWeight: fw$SemiBold),
            ),
          ),
          Expanded(child: $Body()),
        ],
      ),
    );
  }

  Widget $Body() {
    return Column(
      children: [
        Text(
          '恭喜您获得与异性免费语音通话体验～',
          style: TextStyle(fontSize: 18, color: Color(0xFF0A294F), fontWeight: fw$SemiBold),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelfView(size: 72, circle: false),
                    Container(
                      width: 56,
                      height: 56,
                      child: SVGAImg(assets: SVGA.$('心')),
                    ),
                    RectAvatarView(url: '', size: 72),
                  ],
                ),
                AppTextButton(
                  width: double.infinity,
                  height: 40,
                  bgColor: AppPalette.primary,
                  borderRadius: BorderRadius.circular(20),
                  title: Text('立即体验', style: TextStyle(fontSize: 14, color: Colors.white)),
                  onPress: () {
                    Get.back(result: true);

                    CallOverlayCtrl.obj.to();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
