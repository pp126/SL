import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/room/widgets/mic_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class SettingMicDialog extends StatelessWidget {
  SettingMicDialog._();

  static to(ValueChanged<int> callback) async {
    final result = await Get.showBottomSheet(
      SettingMicDialog._(),
      bgColor: AppPalette.sheetDark,
    );

    if (result is int) callback(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: GridLayout(
        crossAxisCount: 4,
        childAspectRatio: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(4, createItem),
      ),
    );
  }

  Widget createItem(int i) {
    return InkResponse(
      child: FittedBox(
        child: MicView(
          Image.asset(IMG.$('room/pos_$i'), scale: 3),
        ),
      ),
      onTap: () => Get.back(result: i),
    );
  }
}
