
import 'package:app/common/theme.dart';
import 'package:app/widgets/customer/app_text_button.dart';
import 'package:flutter/material.dart';

class CommentInputItem extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode commentFocus;
  final double height;
  final EdgeInsetsGeometry padding;
  final ValueChanged<String> onSubmitted;

  CommentInputItem({
    TextEditingController controller,
    FocusNode commentFocus,
    this.onSubmitted,
    double height,
    EdgeInsetsGeometry padding,
  }):controller = controller??TextEditingController(),
        commentFocus = commentFocus??FocusNode(),
    height = height ?? 40,
    padding = padding ?? EdgeInsets.only(left: 16,right: 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: padding,
      alignment: Alignment.centerLeft,
      height: 64,
      child: Row(
        children: <Widget>[
          Expanded(
            child:_buildInputItem(),
          ),
          AppTextButton(
            width: 72,
            height: height,
            bgColor: AppPalette.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            title: Text(
              '发送',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            onPress: () {
              if(onSubmitted != null){
                onSubmitted(controller.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  _buildInputItem(){
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xffF1F0F7),
//            border: Border.all(color: Color(0xffF2F2F2),width: 2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 6),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: height,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
//                child: Image.asset(
//                  'images/book/icon_home_search.webp',
//                  width: 20.0,
//                  height: 20.0,
//                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: commentFocus,
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.black,//光标颜色
                  style: TextStyle(fontSize:15,color: Colors.black,),
                  enableInteractiveSelection:true,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "主动才有机会～",
                    hintStyle: TextStyle(fontSize:15,color: AppPalette.hint,),
                  ),
                  maxLines: 1,
                  onSubmitted: (value) {
                    if(onSubmitted != null){
                      onSubmitted(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}