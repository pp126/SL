import 'dart:ui';

import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/common/uid_box.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/widgets/customer/photo_view.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:app/widgets/network_cache_image.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

///用户动态
class UserMomentPage extends StatefulWidget {
  final int uid;
  final Map userInfo;

  UserMomentPage({this.uid, this.userInfo});

  @override
  _UserMomentPageState createState() => _UserMomentPageState();
}

class _UserMomentPageState extends NetPageList<Map, UserMomentPage> {
  bool isSelf = false;

  @override
  void initState() {
    super.initState();

    isSelf = widget.uid == OAuthCtrl.obj.uid;

    Bus.on<MomentEvent>((data) => doRefresh());
    Bus.on<MomentCommentEvent>((data) => doRefresh());
  }

  @override
  BaseConfig initListConfig() {
    //TODO(1像素)
    final px1 = 1 / window.devicePixelRatio;

    return ListConfig(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      divider: Divider(color: Colors.black12, height: px1, thickness: px1),
    );
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) {
    List photos = widget.userInfo['privatePhoto'];
    return SingleChildScrollView(
      child: Column(
        children: [
          photos.isNotEmpty ? _buildAlbumItem(widget.userInfo) : SizedBox(),
          _buildHeaderItem(widget.userInfo),
          child
        ],
      ),
    );
  }

  _buildAlbumItem(Map userInfo) {
    List photos = userInfo['privatePhoto'];
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    isSelf ? '我的相册' : 'ta的相册',
                    style: TextStyle(
                        color: AppPalette.dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  child: Text(
                    '${photos.length}个',
                    style: TextStyle(color: AppPalette.hint),
                  ),
                ),
              ],
            ),
            Container(
              height: 172,
              child: photos.isEmpty
                  ? SizedBox()
                  : GridView.count(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      crossAxisSpacing: 10.0,
                      crossAxisCount: 1,
                      mainAxisSpacing: 10.0,
                      children: photos.map((e) {
                        return InkWell(
                          onTap: () {
                            List data =
                                photos.map((e) => e['photoUrl']).toList();
                            showPhotoView(context, data, e['photoUrl']);
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  width: 164,
                                  height: 142,
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      child: NetImage(e['photoUrl'],
                                          fit: BoxFit.cover)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            )
          ],
        ));
  }

  ///图片浏览器
  showPhotoView(BuildContext context, List data, String image) {
    Navigator.of(context).push(new FadeRoute(
        page: PhotoViewGalleryScreen(
      images: data,
      index: data.indexOf(image), //传入当前点击的图片的index
      heroTag: image,
    )));
  }

  _buildHeaderItem(Map userInfo) {
    String erbanNo = xMapStr(userInfo, 'erbanNo').toString();
    String userDesc = xMapStr(userInfo, 'userDesc').toString();
    var birth = TimeUtils.formatZHDateTime(
        TimeUtils.getDateStrByMs(xMapStr(userInfo, 'birth', defaultStr: 0)),
        DateFormat.ZH_MONTH_DAY,
        null);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppPalette.background,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '个人信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppPalette.dark,
            ),
          ),
          Spacing.h20,
          DefaultTextStyle(
              style: TextStyle(fontSize: 12, color: AppPalette.primary),
              child: Row(children: [
                UidBox(data: userInfo, height: 26),
                Spacing.w6,
                Text(
                  '复制',
                  style: TextStyle(fontSize: 12, color: AppPalette.primary),
                ).toBtn(26, AppPalette.txtWhite, radius: 4, onTap: () {
                  if (erbanNo.isNotEmpty) {
                    CommonUtils.copyToClipboard(erbanNo);
                    showToast('复制成功');
                  }
                })
              ])),
          Spacing.h20,
          DefaultTextStyle(
              style: TextStyle(fontSize: 12, color: AppPalette.dark),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('生日:$birth'),
                    Spacing.h20,
                    Text(
                      "签名:$userDesc",
                    ),
                  ])),
        ],
      ),
    );
  }

  @override
  Future fetchPage(PageNum page) => Api.Moment.myMomentList(widget.uid, page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return MomentItemView(
      showFollow: false,
      data: item,
    );
  }
}
