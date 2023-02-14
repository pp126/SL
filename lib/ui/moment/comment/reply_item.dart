import 'dart:convert';

import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/page/user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_radius_button.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReplyItem extends StatefulWidget {
  final ValueChanged onReplyClick;
  final data;

  ReplyItem({
    this.onReplyClick,
    this.data,
  });

  @override
  _ReplyItemState createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  double leftWidth = 48;
  bool isSelf = false;

  checkSelf() {
    var uid = xMapStr(widget.data, 'uid');
    isSelf = OAuthCtrl.obj.uid == uid;
  }

  @override
  Widget build(BuildContext context) {
    checkSelf();
    var child = Column(
      children: [
        _userInfoView(),
        Spacing.h16,
        _replyView(),
      ],
    );
    return Container(
      padding: EdgeInsets.fromLTRB(36, 16, 16, 16),
//      color: Colors.red,
      child: child,
    );
  }

  ///用户信息
  _userInfoView() {
    var name = xMapStr(widget.data, 'nick');
    var avatar = xMapStr(widget.data, 'avatar');
    bool isMan = xMapStr(widget.data, 'gender') == 1;
    var likeNum = xMapStr(widget.data, 'commentLikeNum', defaultStr: '0').toString();
    bool isLike = xMapStr(widget.data, 'hasLike') == 1;
    var type = xMapStr(widget.data, 'type', defaultStr: 0);
    var content = xMapStr(widget.data, 'comment', defaultStr: '').toString();
    Widget view = Container();
    if (type == 0) {
      view = Text(
        content,
        style: TextStyle(fontSize: 12, color: AppPalette.txtDark, fontWeight: fw$Regular),
      );
    } else if (type == 1) {
      var contentJson = json.decode(content);
      view = Row(
        children: [
          Text.rich(
              TextSpan(children: [
                TextSpan(text: '送出'),
                TextSpan(
                    text: '  ${xMapStr(contentJson, 'giftName')} x${xMapStr(contentJson, 'giftNum')}',
                    style: TextStyle(color: Color(0xff7C66FF))),
              ]),
              style: TextStyle(fontSize: 12)),
          SizedBox(width: 10),
          NetImage(xMapStr(contentJson, 'giftUrl'), width: 30, height: 30)
        ],
      );
    }

    return Row(
      children: [
        InkWell(
            onTap: () => Get.to(UserPage(uid: xMapStr(widget.data, 'uid', defaultStr: null))),
            child: AvatarView(
              url: avatar,
              size: leftWidth,
            )),
        Spacing.w12,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 14, color: AppPalette.txtDark, fontWeight: fw$Regular),
                  ),
                  Spacing.w4,
                  SvgPicture.asset(SVG.$(isMan ? 'mine/性别_1' : 'mine/性别_2')),
                  Spacing.exp,
                  RadiusGradientButton(
                    height: 30,
                    bgColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    leftIcon: SvgPicture.asset(SVG.$(isLike ? "moment/like" : "moment/unlike")),
                    title: likeNum,
                    textStyle: TextStyle(fontSize: 12, color: AppPalette.tips),
                    onTap: onLikeTap,
                  ),
                ],
              ),
              Spacing.h8,
              view,
            ],
          ),
        ),
      ],
    );
  }

  ///回复
  _replyView() {
    var time = TimeUtils.getNewsTimeStr(xMapStr(widget.data, 'createTime'));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: leftWidth,
          child: SizedBox(),
        ),
        Spacing.w12,
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: AppPalette.hint),
                  ),
                  Spacing.w8,
                  AppTextButton(
                    width: 40,
                    height: 20,
                    bgColor: AppPalette.txtWhite,
                    title: Text(
                      '回复',
                      style: TextStyle(fontSize: 10, color: AppPalette.primary),
                    ),
                    onPress: () {
                      xlog(() => '回复');
                      if (widget.onReplyClick != null) {
                        widget.onReplyClick(widget.data);
                      }
                    },
                  ),
                  Spacing.exp,
                  isSelf
                      ? GestureDetector(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: AppPalette.txtWhite, borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: AppPalette.primary,
                            ),
                          ),
                          behavior: HitTestBehavior.translucent,
                          onTap: _del,
                        )
                      : SizedBox(),
                ],
              ),
              Spacing.h10,
              _replyCommentItem(),
            ],
          ),
        ),
      ],
    );
  }

  ///回复的互动内容
  _replyCommentItem() {
    List data = xMapStr(widget.data, 'answerComments', defaultStr: null);
    if (data == null || data.isEmpty) {
      return SizedBox();
    }
    List<Widget> children = [];
    for (var item in data) {
      var name = xMapStr(item, 'nick');
      var content = xMapStr(item, 'comment', defaultStr: '').toString();
      var time = TimeUtils.getNewsTimeStr(xMapStr(item, 'createTime'));
      bool isLast = item == data.last;
      children.add(Container(
        margin: EdgeInsets.only(bottom: (isLast ? 0 : 12)),
        child: Row(
          children: [
            Text(
              '$name : $content',
              style: TextStyle(fontSize: 10, color: AppPalette.dark, fontWeight: fw$Regular),
              textAlign: TextAlign.left,
            ),
            Spacing.exp,
            Text(
              time,
              style: TextStyle(fontSize: 10, color: AppPalette.hint),
            ),
          ],
        ),
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  ///点赞动态评论
  onLikeTap() {
    bool isLike = xMapStr(widget.data, 'hasLike') == 1;
    var dynamicId = xMapStr(widget.data, 'dynamicId', defaultStr: null);
    var dynamicCommentId = xMapStr(widget.data, 'dynamicCommentId', defaultStr: null);

    simpleSub(
        Api.Moment.likeMomentComment(
          dynamicId,
          dynamicCommentId,
          isLike: isLike,
        ), callback: () {
      setState(() {
        var likeNum = xMapStr(widget.data, 'commentLikeNum', defaultStr: 0) + (isLike ? -1 : 1);
        if (likeNum < 0) likeNum = 0;
        widget.data['hasLike'] = isLike ? 0 : 1;
        widget.data['commentLikeNum'] = likeNum;
      });
    }, msg: isLike ? '取消点赞' : '点赞成功');
  }

  ///删除
  _del() {
    xlog(() => '删除');
    var dynamicCommentId = xMapStr(widget.data, 'dynamicCommentId');

    simpleSub(
        Api.Moment.delMomentReply(
          dynamicCommentId: dynamicCommentId,
        ), callback: () {
      Bus.fire(MomentCommentEvent());
    }, msg: '删除成功');
  }
}
