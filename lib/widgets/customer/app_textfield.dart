import 'package:app/common/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatefulWidget {
  TextEditingController controller;
  String hintText;
  Widget leftIcon;
  double leftWidth;
  String leftStr;
  String leftIconStr;
  double leftIconWidth;
  double leftIconHeight;
  Widget suffixIcon;
  TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  FormFieldValidator<String> validator;
  VoidCallback onEditingComplete;
  VoidCallback onNext;
  final EdgeInsetsGeometry margin;
  bool obscureText = false;
  bool isUnderLine = false;
  bool enabled = true;
  int maxLength;
  FocusNode focusNode;
  TextInputAction textInputAction;


  AppTextFormField({
    this.controller,
    this.hintText,
    this.leftIcon,
    this.leftWidth,
    this.leftStr,
    this.leftIconStr,
    this.leftIconWidth = 18,
    this.leftIconHeight = 24,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onEditingComplete,
    this.margin,
    this.obscureText = false,
    this.isUnderLine = false,
    this.enabled = true,
    int maxLength,
    this.focusNode,
    this.textInputAction,
    this.onNext,
  });

  @override
  _AppTextFormFieldState createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  FocusNode focusNode;
  bool isFocus = false;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String errorTips;
  bool haveInput = false;

  @override
  void initState() {
    super.initState();

    focusNode = widget.focusNode ?? FocusNode();
    // 输入框焦点
    focusNode.addListener(() {
      setState(() {
        isFocus = focusNode.hasFocus;
      });
    });

    widget.controller.addListener(() {
      bool input = widget.controller.text.trim().length>0;
      if(input != haveInput) {
        setState(() {
          haveInput = input;
        });
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    var prefixIcon = Container(
      width: widget.leftWidth,
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.centerRight,
      child: UnconstrainedBox(
        child: widget.leftIcon??
            (widget.leftStr != null ?
                Text(widget.leftStr,style: TextStyle(color: AppPalette.tips, fontSize: 12,height: 1),)
            :Image.asset(widget.leftIconStr,width: widget.leftIconWidth,height: widget.leftIconHeight,color: haveInput?AppPalette.primary:null,)),
      ),
    );

    return Container(
      width: double.infinity,
      margin: widget.margin??EdgeInsets.only(bottom: 20),
      child: TextFormField(
        key: _key,
        enabled: widget.enabled,
        controller: widget.controller,
        focusNode: focusNode,
        maxLength: widget.maxLength,
        style: TextStyle(color: AppPalette.dark, fontSize: 12, height: 1),
        keyboardType:widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onEditingComplete: widget.onEditingComplete??onEditComplete,
        obscureText:widget.obscureText,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
//          focusColor: Colors.white,
          fillColor: AppPalette.divider,
          filled: true,
          border: widget.isUnderLine?UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffEEEEEE),width: 2),):OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(60))),
          errorBorder: widget.isUnderLine?UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF5959),width: 2),):OutlineInputBorder(
            borderSide: BorderSide(color: AppPalette.divider,width: 1),
            borderRadius: BorderRadius.all(Radius.circular(60)),
          ),
          focusedBorder: widget.isUnderLine?UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffEEEEEE),width: 2),):OutlineInputBorder(
            borderSide: BorderSide(color: AppPalette.divider,width: 1),
            borderRadius: BorderRadius.all(Radius.circular(60)),
          ),
          enabledBorder: widget.isUnderLine?UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffEEEEEE),width: 2),):OutlineInputBorder(
            borderSide: BorderSide(color: AppPalette.divider,width: 1),
            borderRadius: BorderRadius.all(Radius.circular(60)),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppPalette.hint, fontSize: 12),
          errorStyle: TextStyle(color: Color(0xffFF0000), fontSize: 10),
          errorText: errorTips,
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 1,
            minHeight: 1,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.only(right: 15),
            child: UnconstrainedBox(
              child: widget.suffixIcon,
            ),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }

  onEditComplete(){
    if(widget.onNext != null){
      var res = widget.validator(widget.controller.text.trim());
      setState(() {
        errorTips = res;
      });
      if(res == null){
        widget.onNext();
      }
    }else if(widget.onEditingComplete != null){
      widget.onEditingComplete();
    }
  }
}