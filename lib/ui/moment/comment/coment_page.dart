import 'dart:ui';

import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/mine/account/account_page.dart';
import 'package:app/ui/moment/comment/comment_input_ietm.dart';
import 'package:app/ui/moment/comment/reply_item.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

///我的动态评论详情
class CommentPage extends StatefulWidget {
  final momentData;

  CommentPage({Key key, this.momentData}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _key = GlobalKey<XFutureBuilderState>();

  bool isMy = false;

  @override
  void initState() {
    super.initState();
    var momentInfo = xMapStr(widget.momentData, 'userDynamic');
    int moment = xMapStr(momentInfo, 'uid', defaultStr: -1);
    int uid = OAuthCtrl.obj.uid;
    isMy = uid == moment;
    Bus.on<MomentCommentEvent>((data) {
      _key.currentState.doRefresh();
    });
  }

  Future<Map> getData() async {
    var momentInfo = xMapStr(widget.momentData, 'userDynamic');
    var dynamicId = xMapStr(momentInfo, 'dynamicMsgId', defaultStr: '');
    return Api.Moment.momentDetail(
      dynamicId.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '评论详情',
        action: isMy
            ? '编辑'.toTxtActionBtn2(onPressed: () => Get.to(AccountPage()))
            : 'moment/more'.toSvgActionBtn(
                color: AppPalette.dark,
                width: 28,
                height: 28,
                onPressed: () => DialogUtils.showChooseDialog(context, isNormal: true, momentData: widget.momentData),
              ),
      ),
      backgroundColor: AppPalette.background,
      body: XFutureBuilder<Map>(
          key: _key,
          futureBuilder: getData,
          onData: (data) {
            return _CommentItem(
              momentData: data,
            );
          }),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final momentData;

  _CommentItem({this.momentData});

  @override
  _CommentItemState createState() => new _CommentItemState();
}

class _CommentItemState extends NetPageList<Map, _CommentItem> {
  TextEditingController _textController;
  FocusNode _commentFocus = FocusNode();
  var currentRePlayInfo;

  ///当前回复的用户评论
  var replyData;

  @override
  void initState() {
    _textController = TextEditingController(text: '');
    _commentFocus.addListener(() {
      if (!_commentFocus.hasFocus) {
        replyData = null;
      }
    });

    Bus.on<MomentCommentEvent>((data) => doRefresh());

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
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
  Widget build(BuildContext context) {
    return ConfigListState(
      buildEmptyView: ([Tuple2<VoidCallback, bool> arg]) => TipsView(
        arg.item1,
        tipsType: TipsType.empty,
        noImage: true,
        message: '暂时没有回复数据哦！',
      ),
      child: super.build(context),
    );
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderItem(),
                  child,
                ],
              ),
            ),
          ),
          _buildInputItem(),
        ],
      );

  _buildHeaderItem() {
    return MomentItemView(
      data: widget.momentData,
      isInComment: true,
      onCommentClick: () {
        //获取焦点
        FocusScope.of(context).requestFocus(_commentFocus);
      },
    );
  }

  _buildInputItem() {
    return CommentInputItem(
      commentFocus: _commentFocus,
      controller: _textController,
      onSubmitted: (value) {
        onSendTap();
      },
    );
  }

  @override
  Future fetchPage(PageNum page) {
    var userInfo = xMapStr(widget.momentData, 'usersDTO');
    var momentInfo = xMapStr(widget.momentData, 'userDynamic');
    var uid = xMapStr(userInfo, 'uid', defaultStr: null);
    var dynamicId = xMapStr(momentInfo, 'dynamicMsgId', defaultStr: null);

    return Api.Moment.momentReplyList(
      uid,
      dynamicId,
      page,
    );
  }

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return ReplyItem(
      data: item,
      onReplyClick: (data) {
        replyData = data;
        //获取焦点
        FocusScope.of(context).requestFocus(_commentFocus);
      },
    );
  }

  ///评论动态
  onSendTap() {
    String content = _textController.text.trim();
    if (content == null || content.isEmpty) {
      showToast('请输入评论');
      return;
    }

    var momentInfo = xMapStr(widget.momentData, 'userDynamic');
    var dynamicId = xMapStr(momentInfo, 'dynamicMsgId', defaultStr: '');
    bool isCommentDynamic = replyData == null;
    simpleSub(
        Api.Moment.sendComment(
          dynamicId: dynamicId,
          content: content,
          answerCommentId: xMapStr(replyData, 'dynamicCommentId', defaultStr: ''),
          answerUid: xMapStr(replyData, 'uid', defaultStr: ''),
          isCommentDynamic: isCommentDynamic, //
        ), callback: () async {
      // 收起键盘
      FocusScope.of(context).requestFocus(FocusNode());
      replyData = null;
      _textController.text = '';
      Bus.fire(MomentCommentEvent());
      Future.delayed(Duration(milliseconds: 200), () {
        doRefresh();
      });
    }, msg: '评论成功');
  }
}
