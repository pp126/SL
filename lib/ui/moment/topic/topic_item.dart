import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/topic/topic_detail_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopicItemView extends StatelessWidget {
  final bool selectStatus;

  ///是否处于选择状态
  final ValueChanged selectCallBack;
  final selectTopic;
  final data;
  final double leftWidth = 48;

  TopicItemView({
    this.data,
    this.selectStatus = false,
    this.selectCallBack,
    this.selectTopic,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = CustomCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _titleView(),
          Spacing.h12,
          _contentView(),
        ],
      ),
    );
    if (selectStatus) {
      bool selected = selectTopic != null ? data['subjectId'] == selectTopic['subjectId'] : false;
      child = Stack(
        children: [
          child,
          Positioned.fill(
            child: Container(
              color: selected ? Colors.transparent : Color(0x80ffffff),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (selectStatus) {
            if (selectCallBack != null) {
              selectCallBack(data);
            }
          } else {
            Get.to(TopicDetailPage(
              topicData: data,
            ));
          }
        },
        child: child);
  }

  ///标题信息
  _titleView() {
    bool selected = selectTopic != null ? data['subjectId'] == selectTopic['subjectId'] : false;
    return Row(
      children: [
        SvgPicture.asset(SVG.$('moment/talk')),
        Spacing.w2,
        Text(
          '${xMapStr(data, 'subjectName')}',
          style: TextStyle(fontSize: 16, color: AppPalette.dark, fontWeight: fw$SemiBold),
        ),
        Spacing.exp,
        Text(
          '${xMapStr(data, 'joinNum', defaultStr: '0')}人参与',
          style: TextStyle(fontSize: 12, color: AppPalette.primary),
        ),
        Spacing.w2,
        selectStatus ? SvgPicture.asset(SVG.$('moment/${selected ? 'selected' : 'unselect'}')) : SizedBox(),
      ],
    );
  }

  ///话题内容
  _contentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${xMapStr(data, 'subjectDetail', defaultStr: '')}',
          style: TextStyle(fontSize: 14, color: AppPalette.dark),
        ),
        Spacing.h8,
        AspectRatio(
          aspectRatio: 303 / 100,
          child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: NetImage('${xMapStr(data, 'coverImgUrl', defaultStr: '')}', fit: BoxFit.fill),
            ),
          ),
        ),
      ],
    );
  }
}
