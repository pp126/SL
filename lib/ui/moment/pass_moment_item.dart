
import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/comment/coment_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_custom_card.dart';
import 'package:flutter/material.dart';

class PassMomentItem extends StatefulWidget {
  final Map data;
  final Color bgColor;
  final EdgeInsets margin;

  PassMomentItem({
    this.data,
    this.bgColor,
    this.margin,
  });

  @override
  _PassMomentItemState createState() => _PassMomentItemState();
}

class _PassMomentItemState extends State<PassMomentItem> {
  final double leftWidth = 48;

  var userInfo;

  var momentInfo;

  @override
  Widget build(BuildContext context) {
    userInfo = xMapStr(widget.data,'usersDTO');
    momentInfo = xMapStr(widget.data,'userDynamic');

    return CustomCard(
      color: widget.bgColor,
      margin: widget.margin??EdgeInsets.fromLTRB(16,0,16,10),
      padding: EdgeInsets.all(10),
      child: _commentView(),
      onPress: (){
        Get.to(CommentPage(momentData: widget.data,));
      },
    );
  }

  ///动态信息
  _commentView() {
    var name = xMapStr(userInfo,'nick');
    var content = xMapStr(momentInfo,'comtent');
    return Row(
      children: [
        _commentImageItem(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16, color: AppPalette.dark),
              ),
              Spacing.h4,
              Text(
                content,
                style: TextStyle(fontSize: 10, color: AppPalette.dark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///动态图片内容，取第一张
  _commentImageItem() {
//    double width = (Screen.width - 16 * 2 - leftWidth - 12 - 20 * 2 - 10 * 2) / 3 - 1;
    String urls = xMapStr(momentInfo,'attachmentUrl');
    bool isEmpty = urls.isEmpty;
    var data = urls.split(',');

    return isEmpty?SizedBox():Container(
      margin: const EdgeInsets.only(right: 8),
      child: NetImage(
        data[0],
        fit: BoxFit.cover,
        width: 60,
        height: 60,
      ),
    );
  }
}
