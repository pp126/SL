import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/topic/topic_detail_page.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopicTitleItem extends StatelessWidget {
  final data;
  final bgColor;
  final bool canJumpDetail;
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;

  TopicTitleItem({
    this.bgColor,
    this.data,
    this.canJumpDetail = true,
    this.height = 40,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    String title = xMapStr(
      data,
      'subjectName',
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(SVG.$('moment/talk'), width: 24, height: 24),
        Spacing.w4,
        Text(
          '$title',
          style: TextStyle(fontSize: 12, color: AppPalette.dark),
          textAlign: TextAlign.center,
        ),
      ],
    ).toBtn(
      height,
      bgColor ?? Colors.white,
      autoSize: true,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      onTap: canJumpDetail //
          ? () => Get.to(TopicDetailPage(topicData: data))
          : null,
    );
  }
}
