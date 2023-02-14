
import 'package:flutter/material.dart';

enum Gravity {
  TOP,
  LEFT,
  RIGHT,
  BOTTOM,
}

class RotationIconText extends StatefulWidget {
  final String text;
  final TextStyle style;

  final Gravity gravity;

  final double height;
  final Widget icon;
  final EdgeInsets padding;
  final EdgeInsets textPadding;
  final VoidCallback onPressed;

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final BorderRadius borderRadius;
  final AnimationController animationController;

  RotationIconText(
      this.text, {
        this.icon,
        this.style,
        double height,
        this.gravity = Gravity.RIGHT,
        EdgeInsets padding,
        this.textPadding = const EdgeInsets.all(8.0),
        this.borderRadius = const BorderRadius.all(Radius.circular(60)),
        this.onPressed,
        this.mainAxisAlignment = MainAxisAlignment.center,
        this.mainAxisSize = MainAxisSize.max,
        this.crossAxisAlignment = CrossAxisAlignment.center,
        this.animationController,
      })  : padding = padding != null
      ? padding
      : (gravity == Gravity.RIGHT || gravity == Gravity.LEFT
      ? EdgeInsets.symmetric(horizontal: 4.0)
      : EdgeInsets.symmetric(vertical: 4.0)),
        height = height ?? 60.0;

  @override
  _RotationIconTextState createState() => _RotationIconTextState();
}

class _RotationIconTextState extends State<RotationIconText> with SingleTickerProviderStateMixin{
  AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(_animationController != null){
      _animationController.dispose();
      _animationController = null;
    }

    super.dispose();
  }
  _getAnimationController(){
    if(widget.animationController != null){
      return widget.animationController;
    }else{
      if(_animationController == null){
        _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 1000),
        );
      }
      return _animationController;
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget iconChild = RotationTransition(
      turns: CurvedAnimation(parent: _getAnimationController(),curve: Curves.linear),
      child: widget.icon ?? SizedBox(),
    );
    List<Widget> children = <Widget>[
      iconChild,
      Container(
        height: widget.height,
        padding: widget.padding,
      ),
      Container(
        child: Padding(
          padding: widget.textPadding,
          child: Text(
            widget.text ?? '',
            style: widget.style ?? TextStyle(fontSize: 13),
          ),
        ),
      )
    ];
    Widget container = (widget.gravity == Gravity.TOP || widget.gravity == Gravity.BOTTOM)
        ? Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      verticalDirection: widget.gravity == Gravity.TOP
          ? VerticalDirection.down
          : VerticalDirection.up,
      children: children,
    )
        : Row(
      textDirection: widget.gravity == Gravity.RIGHT
          ? TextDirection.rtl
          : TextDirection.ltr,
      mainAxisSize: widget.mainAxisSize,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: children,
    );
    if(widget.icon == null) {
      container = Container(
        width: widget.height,
        height: widget.height,
        child: container,
      );
    }
    return widget.onPressed!=null?InkWell(
        onTap: widget.onPressed,
        borderRadius: widget.borderRadius,
        child: container
    ):container;
  }
}