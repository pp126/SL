import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AppSimpleDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<DialogAction> actions;

  AppSimpleDialog({this.title = '提示', this.content, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Material(
        type: MaterialType.transparency,
        textStyle: TextStyle(),
        child: Container(
          width: 375,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [$Content(), $Title()],
          ),
        ),
      ),
    );
  }

  Widget $Content() {
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: 285,
          padding: EdgeInsets.fromLTRB(15, 34, 15, 0),
          child: Column(
            children: [
              content,
              ...actions.map((it) => it.$View).separator(Spacing.h12),
              if (actions.isNotEmpty) Spacing.h16,
            ],
          ),
        ),
      ),
    );
  }

  Widget $Title() {
    return Container(
      width: 398 / 2,
      height: 97 / 2,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(IMG.$('提示框标题背景')), fit: BoxFit.fill, scale: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: fw$SemiBold),
      ),
    );
  }
}

abstract class DialogAction {
  final String title;
  final VoidCallback onTap;

  DialogAction(this.title, this.onTap);

  TextStyle get textStyle;

  BorderSide get side => BorderSide.none;

  Color get canvasColor => Colors.transparent;

  Widget get $View {
    return Material(
      color: canvasColor,
      shape: StadiumBorder(side: side),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 44,
          alignment: Alignment.center,
          child: Text(title, style: textStyle),
        ),
      ),
    );
  }
}

class OkDialogAction extends DialogAction {
  OkDialogAction({String title = '确定', VoidCallback onTap}) : super(title, onTap);

  @override
  TextStyle get textStyle => TextStyle(fontSize: 13, color: Colors.white);

  @override
  Color get canvasColor => AppPalette.primary;
}

class CancelDialogAction extends DialogAction {
  CancelDialogAction({String title = '取消', VoidCallback onTap})
      : super(
          title,
          () {
            Get.back(result: title);

            onTap?.call();
          },
        );

  @override
  TextStyle get textStyle => TextStyle(fontSize: 13, color: AppPalette.primary);

  @override
  BorderSide get side => BorderSide(color: AppPalette.primary);
}
