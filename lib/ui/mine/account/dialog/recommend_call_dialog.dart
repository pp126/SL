import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:app/widgets/grid_layout.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecommendCallDialog extends StatelessWidget {
  final int gender;

  RecommendCallDialog(this.gender);

  final _gk = GlobalKey<XFutureBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          height: 560,
          margin: EdgeInsets.symmetric(horizontal: 17.5),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 107,
                child: Image.asset(IMG.$('推荐关注背景'), fit: BoxFit.fill, scale: 3),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 65,
                child: DefaultTextStyle(
                  style: TextStyle(fontSize: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '挑选心动'),
                            TextSpan(text: gender == 2 ? '男' : '女'),
                            TextSpan(text: '生打招呼'),
                          ],
                        ),
                        style: TextStyle(color: Colors.white, fontWeight: fw$SemiBold),
                      ),
                      Text(
                        '主动出击才有机会哟~',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                width: 340,
                height: 497,
                child: Material(
                  color: AppPalette.txtWhite,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: $DataView(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget $DataView() {
    return XFutureBuilder(
      key: _gk,
      futureBuilder: () => Api.Home.greetingList(),
      onData: (data) {
        final onTap = () => doSub(data.map((it) => it['uid']).toList(growable: false));

        return Column(
          children: [
            Spacing.h16,
            Expanded(
              child: GridLayout(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 3,
                childAspectRatio: 96 / 110,
                children: [for (final Map it in data) xItem(it)],
              ),
            ),
            Spacing.h32,
            Text('一键打招呼', style: TextStyle(color: Colors.white, fontSize: 14)) //
                .toBtn(48, AppPalette.primary, onTap: onTap),
            Container(
              width: 64,
              height: 52,
              child: InkWell(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(IMG.$('重新推荐'), scale: 3),
                    Spacing.w4,
                    Text(
                      '换一批',
                      style: TextStyle(color: AppPalette.tips, fontSize: 12),
                    )
                  ],
                ),
                onTap: () => _gk.currentState.doRefresh(),
              ),
            ),
          ],
        );
      },
    );
  }

  xItem(Map data) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 16,
            child: AvatarView(url: data['avatar'], size: 48),
          ),
          Positioned(
            top: 56,
            width: 16,
            height: 16,
            child: SvgPicture.asset(SVG.$('mine/性别_${data['gender']}')),
          ),
          Positioned(
            left: 8,
            right: 8,
            height: 20,
            bottom: 16,
            child: Text(
              data['nike'],
              softWrap: false,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppPalette.txtDark),
            ),
          ),
        ],
      ),
    );
  }

  void doSub(List ids) {
    final api = Api.Home.clickGreeting(ids);

    simpleSub(api, msg: null, callback: () async {
      final data = await api;

      Get.back(result: data == null ? null : data['uid']);
    });
  }
}
