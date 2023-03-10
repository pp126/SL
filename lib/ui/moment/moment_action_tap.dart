import 'package:app/event/moment_event.dart';
import 'package:app/model/ParamInfo.dart';
import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/common/report_mixin.dart';
import 'package:app/ui/moment/post/post_page.dart';
import 'package:app/widgets/customer/app_bottom_sheet.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:app/widgets/customer/triangle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../tools.dart';

class ActionTap extends StatefulWidget {
  final momentData;

  ActionTap({this.momentData});

  @override
  _ActionTapTapState createState() => _ActionTapTapState();
}

class _ActionTapTapState extends State<ActionTap> with WidgetsBindingObserver {
  void _onAfterRendering(Duration timeStamp) {
    RenderObject renderObject = context.findRenderObject();
    Size size = renderObject.paintBounds.size;
    var vector3 = renderObject.getTransformTo(null)?.getTranslation();
    DialogUtils.showChooseDialog(context, size: size, vector3: vector3, isNormal: false, momentData: widget.momentData);
  }

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        icon: SvgPicture.asset(
          SVG.$('moment/more'),
          fit: BoxFit.fill,
          width: 24,
          height: 24,
        ),
        onPress: () {
          WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
        });
  }
}

class MonentActionItem extends StatefulWidget {
  final Size size;
  final vector3;
  final bool isNormal;
  final momentData;

  MonentActionItem({
    this.size,
    this.vector3,
    this.isNormal = true,
    this.momentData,
  });

  @override
  _MonentActionItemState createState() => _MonentActionItemState();
}

class _MonentActionItemState extends State<MonentActionItem> with ReportMixin {
  List<ParamInfo> data;
  var reasons;
  bool isSelf = false;

  @override
  void initState() {
    super.initState();

    checkSelf();
    requestForData();
  }

  checkSelf() {
    var userInfo = xMapStr(widget.momentData, 'usersDTO');
    var uid = xMapStr(userInfo, 'uid');
    isSelf = OAuthCtrl.obj.uid == uid;
  }

  requestForData() async {
    reasons = await Api.Moment.reportReasonList(isDynamic: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isNormal ? _buildNormalItem(context) : _buildItem(context);
  }

  _buildNormalItem(BuildContext context) {
    var list = List();
    if (isSelf) {
      list.add('??????');
    } else {
      list.add('??????');
      list.add('?????????');
      list.add('??????');
    }
    return CommonBottomSheet(
      list: list,
      onItemClickListener: (index, value) async {
        switch (index) {
          case 0:
            {
              if (isSelf) {
                _del(context);
              } else {
                Get.back();
                reportDynamic(widget.momentData);
              }
            }
            break;
          case 1:
            {
              _black(context);
            }
            break;
          case 2:
            {
              _pass(context);
            }
            break;
        }
      },
    );
  }

  _buildItem(BuildContext context) {
    final double wx = widget.size.width;
//    final double wy = widget.size.height;
    final double dx = widget.vector3[0] - 5;
    final double dy = widget.vector3[1] + 5;
    final double w = MediaQuery.of(context).size.width;
//    final double h = MediaQuery.of(context).size.height;

//    final double trangleW = 10;
    final double trangleh = 8;
    final double marginW = wx / 8;
//    print('wx=$wx\nwy=$wy\ndx=$dx\ndy=$dy\nw=$w\nh=$h');
    data = isSelf
        ? [
            ParamInfo(
              name: '??????',
              onPress: () {
                _del(context);
              },
            ),
          ]
        : [
            ParamInfo(
              name: '??????',
              onPress: () {
                Get.back();
                reportDynamic(widget.momentData);
              },
            ),
            ParamInfo(diviler: true),
            ParamInfo(
              name: '?????????',
              onPress: () {
                _black(context);
              },
            ),
            ParamInfo(
              diviler: true,
            ),
            ParamInfo(
              name: '??????',
              onPress: () {
                _pass(context);
              },
            ),
          ];
    List<Widget> children = data.map((e) => _buildActionItem(context, e)).toList();
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Text(''),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Positioned(
              left: dx < w / 2 ? dx : null,
              right: dx < w / 2 ? null : (w - dx - wx),
              top: dy + trangleh,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(2.0),
                  ),
                  color: Color(0xff514F5C),
                ),
                width: 174,
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            ),
            Positioned(
              left: dx < w / 2 ? dx + marginW : null,
              right: dx < w / 2 ? null : (w - dx - wx + marginW),
              top: dy + 1,
              child: ClipPath(
                clipper: Triangle(dir: -1),
                child: Container(
                  width: 15.0,
                  height: trangleh,
                  color: Color(0xff514F5C),
                  child: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, ParamInfo info) {
    return info.diviler
        ? Container(
            color: DividerTheme.of(context).color,
            width: 1,
            height: 8,
          )
        : Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Center(
                child: Text(
                  info.name,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              onTap: info.onPress,
            ),
          );
  }

  ///?????????
  _black(BuildContext context) {
    Navigator.pop(context);
    xlog(() => '?????????');
    var userInfo = xMapStr(widget.momentData, 'usersDTO');
    var blackUid = xMapStr(userInfo, 'uid');

    simpleSub(
        Api.Moment.black(
          blackUid: blackUid,
        ), callback: () {
      Bus.fire(MomentEvent());
    }, msg: '???????????????');
  }

  ///??????
  _pass(BuildContext context) {
    Navigator.pop(context);
    PostPage.to(momentData: widget.momentData);
  }

  ///??????
  _del(BuildContext context) {
    Navigator.pop(context);
    xlog(() => '??????');
    var userDynamic = xMapStr(widget.momentData, 'userDynamic');
    var dynamicId = xMapStr(userDynamic, 'dynamicMsgId');

    simpleSub(
        Api.Moment.delMoment(
          dynamicId: dynamicId,
        ), callback: () {
      Bus.fire(MomentEvent());
    }, msg: '????????????');
  }
}

class MoreItem extends StatefulWidget {
  final menuData;
  final uid;
  final dynamicMsgId;
  final color;
  final bool isUser;

  MoreItem({this.menuData, this.dynamicMsgId, this.uid, this.isUser = true, this.color});

  @override
  MoreItemState createState() => new MoreItemState();
}

class MoreItemState extends State<MoreItem> with ReportMixin {
  List<ParamInfo> data;
  var reasons;

  @override
  void initState() {
    super.initState();
    requestForData();
  }

  requestForData() async {
    reasons = await Api.Moment.reportReasonList(isDynamic: !widget.isUser);
  }

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        icon: SvgPicture.asset(
          SVG.$(
            'moment/more',
          ),
          fit: BoxFit.fill,
          width: 28,
          height: 28,
          color: widget.color,
        ),
        onPress: () {
          WidgetsBinding.instance.addPostFrameCallback(_onMoreTap);
        });
  }

  void _onMoreTap(Duration timeStamp) {
    var data = ['??????', '?????????'];
    if (widget.menuData != null) {
      data = widget.menuData;
    }
    return DialogUtils.showCupertinoPopup(
      context,
      data: data,
      onItemClickListener: (index, value) async {
        switch (value) {
          case '??????':
            Get.back();

            reportUser(widget.uid,false);
            break;
          case '?????????':
            _black(context);
            break;
        }
      },
    );
  }

  ///?????????
  _black(BuildContext context) {
    Navigator.pop(context);
    xlog(() => '?????????');
    simpleSub(
        Api.Moment.black(
          blackUid: widget.uid,
        ), callback: () {
      Bus.fire(MomentEvent());
    }, msg: '???????????????');
  }
}
