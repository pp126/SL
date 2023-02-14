
import 'package:app/common/theme.dart';
import 'package:app/model/ParamInfo.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/post/post_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:flutter/material.dart';

///发布状态类型
class PostTypeSheet extends StatelessWidget {
  final String title;
  final String ruleStr;

  PostTypeSheet({
    this.title,
    this.ruleStr,
  });

  @override
  Widget build(BuildContext context) {
    var data = [
      PostType(
        title: '发布普通动态',
        bgColor: AppPalette.primary,
        titleColor: Colors.white,
        onPress: (){
          Navigator.pop(context);
          PostPage.to(typeInfo: ParamInfo(name: '发布普通动态',type: 1));
        },
      ),
      PostType(
        title: '发布心愿',
        bgColor: AppPalette.txtWhite,
        titleColor: AppPalette.primary,
        onPress: (){
          Navigator.pop(context);
          PostPage.to(typeInfo: ParamInfo(name: '发布心愿',type: 2));
        },
      ),
    ];
    var children = data.map((item){
      return Row(
        children: [
          Spacing.w12,
          Expanded(
            child: Center(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 16,color: item.titleColor),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: item.titleColor,
          )
        ],
      ).toBtn(78, item.bgColor,
          margin: const EdgeInsets.only(top:20,left: 15,right: 15),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          radius: 12,
          onTap: item.onPress
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      height: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          AppIconButton(
              icon: Icon(
                Icons.close,
                size: 32,
                color: AppPalette.dark,
              ),
              onPress: () {
                Navigator.pop(context);
              }
          ),
          ...children,
        ],
      ),
    );
  }
}
class PostType{
  final String title;
  final Color titleColor;
  final Color bgColor;
  final VoidCallback onPress;

  PostType({
    this.title,
    this.titleColor,
    this.bgColor,
    this.onPress,
  });
}