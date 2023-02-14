import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

///Created by Seven on 2018/11/28.
///用于左右排列的布局
class ItemContainer extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget middle;
  final Widget trailing;
  final bool isLine;
  final double height;
  final bool showBorder;

  final bool expand;
  final VoidCallback onPress;

  ItemContainer({
    this.leading,
    this.title,
    this.middle,
    this.trailing,
    double height,
    bool expand,
    this.isLine = true,
    bool showBorder,
    this.onPress,
  })  : height = height ?? 48.0,
        expand = expand ?? true,
        showBorder = showBorder ?? false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPress,
      child: Container(
        height: height,
        margin: showBorder?const EdgeInsets.only(bottom: 20):null,
        padding: showBorder?const EdgeInsets.fromLTRB(15, 0, 15, 0):null,
        decoration: BoxDecoration(
          border: showBorder?
          Border.all(color: Color(0xffF1EEEC),width: 1)
              :(isLine
              ? Border(bottom: Divider.createBorderSide(context,color: Color(0xffF1EEEC),width: 1))
              : null),
          borderRadius: showBorder?BorderRadius.all(Radius.circular(height)):null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              leading ?? SizedBox(),
              title ?? SizedBox(),
              expand
                  ? Expanded(child: middle ?? SizedBox())
                  : (middle ?? SizedBox()),
              trailing ?? SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

///用于左右排列的布局
class ItemInputContainer extends ItemContainer {
  final ValueChanged<String> onChange;
  final List<TextInputFormatter> inputFormatters;

  ItemInputContainer({
    ItemInfo info,
    Widget leading,
    Widget title,
    Widget trailing,
    double height,
    bool showBorder,
    this.onChange,
    this.inputFormatters,
  }) :super(
    leading: leading,
    title: title,
    height:height,
    showBorder:showBorder,
    middle: Container(
//          padding: EdgeInsets.only(left: 10,right: 10),
      child: TextField(
        controller: info?.controller,
        style: info?.style,
        textAlign: info.textAlign,
        obscureText: info.isPassword,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: info.hint,
          hintStyle: info.hintStyle,
        ),
        enabled: info?.isEnable,
        keyboardType: info?.inputType,
        focusNode: info?.focusNode,
        onTap: (){

        },
      ),
    ),
    trailing: trailing,
    expand:true,
    onPress:info.onPress,
    isLine:info.isLine,
  );
}

class ItemInfo {
  TextEditingController controller;
  bool isEnable;
  TextInputType inputType;
  TextStyle style;
  TextStyle hintStyle;
  VoidCallback onPress;
  bool isEdit;
  bool isLine;
  bool isPassword;
  String hint;//输入框提示语
  String userNameError;//输入错误提示语
  TextAlign textAlign;
  FocusNode focusNode;

  ItemInfo(
      {TextEditingController controller,
        this.isEnable = true,
        this.isEdit = false,
        this.isLine = true,
        this.isPassword = false,
        this.inputType = TextInputType.emailAddress,
        this.onPress,
        this.hint,
        this.userNameError,
        this.textAlign = TextAlign.start,
        TextStyle style,
        TextStyle hintStyle,
        this.focusNode,
      })
      : style =
      style ?? TextStyle(fontSize: 15,color: Colors.black),
        hintStyle =
            hintStyle ?? TextStyle(fontSize: 15,color: Color(0xFFCDCDCD)),
        controller = controller ?? TextEditingController();
}
