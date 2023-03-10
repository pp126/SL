import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/store/society_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/certify/certify_page.dart';
import 'package:app/ui/mine/fans/fan_page.dart';
import 'package:app/ui/mine/fans/follow_page.dart';
import 'package:app/ui/mine/moment/my_moment_page.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/mine/service/servic_page.dart';
import 'package:app/ui/mine/set/set_page.dart';
import 'package:app/ui/mine/shop/package_page.dart';
import 'package:app/ui/mine/shop/shop_page.dart';
import 'package:app/ui/mine/society/details/society_details_page.dart';
import 'package:app/ui/mine/society/noin_society_page.dart';
import 'package:app/ui/mine/society/society_page.dart';
import 'package:app/ui/mine/task/task_page.dart';
import 'package:app/ui/mine/today_user_page.dart';
import 'package:app/ui/mine/wallet/wallet_page.dart';
import 'package:app/ui/mine/young/young_recommend_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'activity/activity_page.dart';
import 'feedback/feedback_page.dart';
import 'invitation/invitation_page.dart';
import 'level/level_page.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16, top: Get.mediaQuery.padding.top),
        child: Column(
          children: <Widget>[
            SizedBox(height: 160, child: _UserInfoView()),
            _ActionView(),
          ],
        ),
      ),
    );
  }
}

class _UserInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        infoView(),
        countView(),
      ],
    );
  }

  Widget infoView() {
    return Container(
      height: 82,
      child: OAuthCtrl.use(
        builder: (info) {
          final userNo = info['erbanNo'];
          return InkWell(
            onTap: () => Get.to(UserPage(uid: info['uid'])),
            child: Row(
              children: [
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  child: SelfView(size: 78),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(
                            info['nick'],
                            style: TextStyle(
                                fontSize: 20,
                                color: AppPalette.dark,
                                fontWeight: fw$SemiBold),
                          ),
                          SvgPicture.asset(SVG.$('mine/??????_${info['gender']}'))
                        ],
                      ),
                      DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 10, color: AppPalette.primary, height: 1),
                        child: Row(
                          children: [
                            UidBox(data: info, height: 20),
                            Spacing.w6,
                            Text('??????',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        height: 1))
                                .toBtn(
                              20,
                              AppPalette.primary,
                              onTap: () => CommonUtils.copyToClipboard(userNo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                RightArrowIcon(),
                Spacing.w16,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget countView() {
    final shopBtn = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Get.to(ShopPage().toOverlay()),
      child: Container(
        width: 120,
        height: 56,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SvgPicture.asset(SVG.$('mine/??????')),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text('??????',
                      style: TextStyle(
                          fontSize: 10, color: Colors.white, height: 1))
                  .toAssImg(20, 'mine/??????'),
            ),
          ],
        ),
      ),
    );

    return Container(
      height: 56,
      child: OAuthCtrl.use(builder: (info) {
        final data = [
          ['${info['followNum']}', '??????', () => Get.to(MyFollowPage())],
          ['${info['fansNum']}', '??????', () => Get.to(MyFanPage())],
          ['${info['visitorCount']}', '??????', () => Get.to(TodayUserPage())],
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // shopBtn,
            for (final it in data)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: it[2],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        it[0],
                        style: TextStyle(
                            fontSize: 20,
                            color: AppPalette.dark,
                            fontWeight: fw$SemiBold),
                        textScaleFactor: 1.0,
                      ),
                      Spacing.h2,
                      Container(
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          it[1],
                          style:
                              TextStyle(fontSize: 12, color: AppPalette.hint),
                          textScaleFactor: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Spacing.w16,
          ],
        );
      }),
    );
  }
}

class _ActionView extends StatelessWidget {
  final _divider = PreferredSize(
    child: Divider(height: px1, indent: 50, endIndent: 15),
    preferredSize: Size.fromHeight(px1),
  );

  @override
  Widget build(BuildContext context) {
    //todo ????????????
    final data = [
      // ['????????????', '????????????', '????????????', '????????????'],
      ['????????????', '????????????', '????????????'],
      // ['????????????', '????????????', '???????????????', '????????????', '????????????', '???????????????'],
      ['????????????', '????????????', '???????????????'],
      ['????????????', '??????', '????????????'],
    ].map((it) {
      final items = it
          .map((it) => TableItem(
              icon: SvgPicture.asset(SVG.$('mine/$it')),
              title: it,
              onTap: () => onItemClick(it)))
          .toList(growable: false);

      return TableGroup(
        items,
        backgroundColor: Colors.white,
        textStyle: TextStyle(
            fontSize: 14, color: AppPalette.dark, fontWeight: fw$SemiBold),
        createDivider: () => _divider,
      );
    }).toList(growable: false);

    return TableView(data, spacing: 10, itemExtent: 56);
  }

  void onItemClick(String item) {
    switch (item) {
      case '????????????':
        Get.to(WalletPage());
        break;
      case '????????????':
        Get.to(MyPackagePage());
        break;
      case '????????????':
        Get.to(LevelPage());
        break;
      case '????????????':
        Get.to(ActivityPage());
        break;
      case '???????????????':
        Get.to(InvitationPage());
        break;
      case '????????????':
        Get.to(TaskPage());
        break;
      case '???????????????':
        Get.to(YoungRecommendPage());
        break;
      case '????????????':
        Get.to(FeedBackPage());
        break;
      case '??????':
        Get.to(SetPage());
        break;
      case '????????????':
        Get.to(MyMomentPage());
        break;
      case '????????????':
        {
          simpleSub(
            () async {
              final value = await SocietyCtrl.obj.fetchInfo();
              if (value['userSocietyType'] == UserSocietyType.noSociety) {
                Get.to(NoinSocietyPage());
              } else if (value['userSocietyType'] ==
                  UserSocietyType.applyCreateSociety) {
                Get.to(SocietyDetailsPage(value));
              } else {
                Get.to(SocietyPage(value));
              }
            },
            msg: null,
          );
        }
        break;
      case '????????????':
        Get.to(CertifyPage());
        break;
      case '????????????':
        Get.to(ServicPage());
        break;
    }
  }
}
