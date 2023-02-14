import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/audit_ctrl.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/screen.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/ui/moment/comment/coment_page.dart';
import 'package:app/ui/moment/moment_action_tap.dart';
import 'package:app/ui/moment/pass_moment_item.dart';
import 'package:app/ui/moment/topic/topic_title_item.dart';
import 'package:app/ui/room/gift_bottom_sheet.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_custom_card.dart';
import 'package:app/widgets/customer/app_net_image.dart';
import 'package:app/widgets/customer/app_radius_button.dart';
import 'package:app/widgets/customer/photo_view.dart';
import 'package:app/widgets/customer/vertical_text.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MomentItemView extends StatefulWidget {
  final bool showFollow;
  final bool isInComment;

  ///是否在评论页
  final VoidCallback onCommentClick;
  final Map data;

  MomentItemView({
    this.data,
    this.showFollow = true,
    this.isInComment = false,
    this.onCommentClick,
  });

  @override
  _MomentItemViewState createState() => _MomentItemViewState();
}

class _MomentItemViewState extends State<MomentItemView> {
  double leftWidth = 48;

  var userInfo;

  var momentInfo;

  var forwardDynamic;

  var subjectName;

  @override
  Widget build(BuildContext context) {
    userInfo = xMapStr(widget.data, 'usersDTO');
    momentInfo = xMapStr(widget.data, 'userDynamic');
    forwardDynamic = xMapStr(widget.data, 'forwardDynamic', defaultStr: null);
    subjectName = xMapStr(momentInfo, 'subjectName', defaultStr: null);

    var child = Column(
      children: [
        _userInfoView(),
        Spacing.h12,
        _momentView(),
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: goToCommentDetail,
      child: widget.isInComment
          ? CustomCard(
//        color: Colors.white,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: child,
            )
          : CustomCard(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: EdgeInsets.all(16),
              child: child,
            ),
    );
  }

  ///用户信息
  _userInfoView() {
    var name = xMapStr(userInfo, 'nick');
    var avatar = xMapStr(userInfo, 'avatar');
    bool isMan = xMapStr(userInfo, 'gender') == 1;
    var time = TimeUtils.getNewsTimeStr(xMapStr(momentInfo, 'createTime'));
    var child = Text(
      name,
      style: TextStyle(fontSize: 14, color: AppPalette.dark, fontWeight: fw$SemiBold),
    );
    return Row(
      children: [
        InkWell(
          onTap: () => Get.to(UserPage(uid: xMapStr(userInfo, 'uid', defaultStr: null))),
          child: AvatarView(
            size: leftWidth,
            url: avatar,
          ),
        ),
        Spacing.w12,
        Expanded(
          child: Container(
            height: leftWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        child,
                        Spacing.w4,
                        SvgPicture.asset(SVG.$(isMan ? 'mine/性别_1' : 'mine/性别_2')),
                        Spacing.w4,
                        WealthIcon(data: userInfo, height: 16),
                        Spacing.w4,
                        CharmIcon(data: userInfo, height: 16),
                      ],
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: AppPalette.hint),
                    ),
                  ],
                ),
                Spacing.exp,
                widget.isInComment
                    ? SizedBox.shrink()
                    : Transform.translate(
                        offset: Offset(10, -5),
                        child: ActionTap(
                          momentData: widget.data,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///动态
  _momentView() {
    List list = xMapStr(widget.data['userDynamic'], 'giftSum', defaultStr: []);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _followItem(),
        Spacing.w12,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${xMapStr(momentInfo, 'comtent')}',
                style: TextStyle(fontSize: 12, color: AppPalette.dark, fontWeight: fw$SemiBold),
              ),
              Spacing.h8,
              _topicItem(),
              _userCommentImageItem(),
              _passCommentItem(),
              Spacing.h8,
              _momentReplayItem(),
              Spacing.h8,
              if (list.isNotEmpty)
                GridLayout(
                  children: [for (Map data in list) _GifItem(data)],
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                )
            ],
          ),
        ),
      ],
    );
  }

  ///礼物
  Widget _GifItem(Map data) {
    return Stack(
      children: [
        NetImage(
          xMapStr(data, 'giftUrl', defaultStr: ''),
          width: 30,
          height: 30,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Text(
            '${xMapStr(data, 'giftNum', defaultStr: 0)}',
            style: TextStyle(color: Colors.white, fontSize: 7),
          ).toWarp(color: Color(0xff7C66FF), padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1)),
        )
      ],
    );
  }

  ///关注状态
  Widget _followItem() {
    bool isFollow = xMapStr(userInfo, 'isFan', defaultStr: false); //是否关注
    double width = 24;
    double height = 76;
    return Container(
      width: leftWidth,
      padding: EdgeInsets.symmetric(horizontal: (leftWidth - width) / 2.0),
      child: widget.showFollow
          ? VerticalTextContainer(
              width: width,
              height: height,
              topIcon: SvgPicture.asset(
                SVG.$(isFollow ? 'moment/follow' : 'moment/unfollow'),
                width: 16,
                height: 16,
                color: isFollow ? AppPalette.hint : AppPalette.primary,
              ),
              text: isFollow ? '已\n关\n注' : '关\n注\nta',
              textStyle: TextStyle(
                color: isFollow ? AppPalette.hint : AppPalette.primary,
                fontSize: 10,
              ),
              onTap: onFollowTap,
            )
          : SizedBox(),
    );
  }

  ///转发动态内容
  _passCommentItem() {
    bool isPass = forwardDynamic != null;
    return isPass
        ? Container(
            child: PassMomentItem(
              data: {
                "userDynamic": forwardDynamic,
                "usersDTO": xMapStr(widget.data, 'forwardUsersDTO', defaultStr: null),
              },
              bgColor: AppPalette.txtWhite,
              margin: EdgeInsets.zero,
            ),
          )
        : SizedBox();
  }

  ///动态图片内容
  _userCommentImageItem() {
    double width = (Screen.width - 16 * 2 - leftWidth - 12 - 20 * 2 - 10 * 2) / 3 - 1;
    String urls = xMapStr(momentInfo, 'attachmentUrl');
    bool isEmpty = urls.isEmpty;
    var data = urls.split(',');
    var children = data.map((e) {
      return GestureDetector(
        onTap: () {
          showPhotoView(e);
        },
        child: AppNetImage(
          defaultImageWidth: width,
          defaultImageHeight: width,
          radius: 6.0,
          netImageUrl: e,
          isHead: false,
          fit: BoxFit.cover,
        ),
      );
    }).toList();

    return isEmpty
        ? SizedBox()
        : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: children,
          );
  }

  ///转发动态内容
  _topicItem() {
    bool isTopic = subjectName != null;
    return isTopic
        ? Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TopicTitleItem(
              data: momentInfo,
              bgColor: AppPalette.txtWhite,
              height: 30,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            ),
          )
        : SizedBox();
  }

  ///动态互动
  _momentReplayItem() {
    bool isLike = xMapStr(momentInfo, 'hasLike') == 1;
    var data = [
      [
        '送礼物',
        'moment/gift',
        TextStyle(fontSize: 12, color: AppPalette.pink),
        MainAxisAlignment.start,
        EdgeInsets.only(right: 10),
        () => GiftBottomSheet.to(GiftSend2MomentCtrl(userInfo, momentInfo['dynamicMsgId'])),
      ],
      [
        '${xMapStr(momentInfo, 'commentNum', defaultStr: '0')}',
        'moment/commend',
        TextStyle(fontSize: 12, color: AppPalette.tips),
        MainAxisAlignment.end,
        EdgeInsets.only(right: 10),
        goToCommentDetail
      ],
      [
        '${xMapStr(momentInfo, 'likeNum', defaultStr: '0')}',
        isLike ? 'moment/like' : 'moment/unlike',
        TextStyle(fontSize: 12, color: AppPalette.tips),
        MainAxisAlignment.end,
        EdgeInsets.only(right: 0),
        () {
          onLikeTap();
        }
      ],
    ];
    List<Widget> children = [];
    children.addAll(data.map((item) {
      return RadiusGradientButton(
//        width: 80,
        height: 30,
        margin: item[4],
        textStyle: item[2],
        padding: EdgeInsets.zero,
        mainAxisAlignment: item[3],
        leftIcon: SvgPicture.asset(SVG.$(item[1])),
        title: item[0],
        onTap: item[5],
      );
    }).toList());
    children.insert(1, Spacing.exp);
    return Row(
      children: children,
    );
  }

  goToCommentDetail() {
    if (widget.isInComment) {
      if (widget.onCommentClick != null) {
        widget.onCommentClick();
      }
    } else {
      Get.to(CommentPage(
        momentData: widget.data,
      ));
    }
  }

  ///点赞动态
  onLikeTap() {
    bool isLike = xMapStr(momentInfo, 'hasLike') == 1;
    var dynamicId = xMapStr(momentInfo, 'dynamicMsgId', defaultStr: null);

    simpleSub(
        Api.Moment.likeMoment(
          dynamicId,
          isLike: isLike,
        ), callback: () {
      if (widget.isInComment) {
        Bus.fire(MomentEvent());
      }
      setState(() {
        var likeNum = xMapStr(momentInfo, 'likeNum', defaultStr: 0) + (isLike ? -1 : 1);
        if (likeNum < 0) likeNum = 0;
        widget.data['userDynamic']['hasLike'] = isLike ? 0 : 1;
        widget.data['userDynamic']['likeNum'] = likeNum;
      });
    }, msg: isLike ? '取消点赞' : '点赞成功');
  }

  ///图片浏览器
  showPhotoView(String image) {
    String urls = xMapStr(momentInfo, 'attachmentUrl');
    List data = urls.split(',');
    Navigator.of(context).push(new FadeRoute(
        page: PhotoViewGalleryScreen(
      images: data,
      index: data.indexOf(image), //传入当前点击的图片的index
      heroTag: image,
    )));
  }

  ///关注用户
  onFollowTap() {
    bool isFollow = xMapStr(userInfo, 'isFan', defaultStr: false); //是否关注
    var uid = xMapStr(userInfo, 'uid', defaultStr: null);

    simpleSub(
        Api.Home.followUser(
          likedUid: uid,
          isFollow: isFollow,
        ), callback: () {
      if (widget.isInComment) {
        Bus.fire(MomentEvent());
      }
      setState(() {
        widget.data['usersDTO']['isFan'] = !isFollow;
      });
      OAuthCtrl.obj.doRefresh();
    }, msg: isFollow ? '取消关注' : '关注成功');
  }
}
