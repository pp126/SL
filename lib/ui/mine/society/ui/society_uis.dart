import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/society/society_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_net_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../tools.dart';

class SocietySubItem extends StatelessWidget {
  final Map data;
  final int index;
  final bool showOrder;
  final bool showApply;
  final bool showCancelApply;
  final VoidCallback refreshCallBack;
  final EdgeInsetsGeometry padding;

  SocietySubItem({
    this.data,
    this.index,
    this.showOrder = true,
    this.showApply = false,
    this.showCancelApply = false,
    this.refreshCallBack,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    SvgPicture crown;
    switch (index) {
      case 0:
        crown = SvgPicture.asset(SVG.$('home/rank/crown_1'));
        break;
      case 1:
        crown = SvgPicture.asset(SVG.$('home/rank/crown_2'));
        break;
      case 2:
        crown = SvgPicture.asset(SVG.$('home/rank/crown_3'));
        break;
    }

    return InkWell(
      onTap: () {
        Get.to(SocietyPage(data));
      },
      child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            if(showOrder)crown != null
                ? crown
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text((index + 1).toString(), style: TextStyle(color: AppPalette.tips, fontSize: 16)),
            ),
            if(showOrder)SizedBox(width: 10),
            AppNetImage(
              defaultImageWidth: 52,
              defaultImageHeight: 52,
              radius: 6.0,
              netImageUrl: data['familyLogo'],
              isHead: false,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: Get.width * 0.35),
                    child: Text(
                        data['familyName'],
                        style: TextStyle(color: AppPalette.dark, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(right: 4, child: Text('实习', style: TextStyle(color: Colors.white, fontSize: 7)))
                      .toAssImg(16, 'mine/society/工会')
                ]),
                SizedBox(height: 1),
                Row(children: [
                  SvgPicture.asset(SVG.$('mine/society/人深灰')),
                  Text(data['member'].toString(), style: TextStyle(color: AppPalette.hint, fontSize: 10))
                ]),
                SizedBox(height: 3),
                Text(data['familyNotice'], style: TextStyle(color: AppPalette.tips, fontSize: 10))
              ]),
            ),
            Column(

              children: [
                Text('贡献值：${data['integral']}',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: AppPalette.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                if(showApply) Text('申请',
                  style: TextStyle(fontSize: 10,color: Colors.white,height: 1),
                ).toBtn(24, AppPalette.primary,
                    width: 45,
                    margin: EdgeInsets.only(top: 4),
                  onTap: (){
                    simpleSub(Api.Family.applyJoinFamilyTeam(familyId: data['familyId'].toString()), msg: '申请成功',
                        callback: () {
                          if(refreshCallBack != null){
                            refreshCallBack();
                          }
                        });
                  }
                ),
                if(showCancelApply) XCancelApplySociety(
                  data: data,
                  refreshCallBack: refreshCallBack,
                ),
              ],
            ),
          ])),
    );
  }
}

class XCancelApplySociety extends StatelessWidget {
  final Map data;
  final VoidCallback refreshCallBack;

  XCancelApplySociety({
    this.data,
    this.refreshCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return Text('取消申请',
      style: TextStyle(fontSize: 10,color: Colors.white),
    ).toBtn(24, AppPalette.primary,
        margin: EdgeInsets.only(top: 4),
        onTap: (){
          simpleSub(Api.Family.cancelApplyJoinFamilyTeam(familyId: data['familyId'].toString()), msg: '申请成功',
              callback: () {
                if(refreshCallBack != null){
                  refreshCallBack();
                }
              });
        }
    );
  }
}