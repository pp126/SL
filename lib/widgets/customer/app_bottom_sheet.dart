import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 底部弹出框
class CommonBottomSheet extends StatefulWidget {
  CommonBottomSheet({Key key, this.list,this.title,this.message,this.onItemClickListener})
      : assert(list != null),
        super(key: key);
  final List list;
  final String title;
  final String message;
  final OnItemClickListener onItemClickListener;
  @override
  _CommonBottomSheetState createState() => _CommonBottomSheetState();
}
typedef OnItemClickListener = void Function(int index,String value);

class _CommonBottomSheetState extends State<CommonBottomSheet> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> actions = widget.list.map((e){
      return _buildItem(e);
    }).toList();
    return CupertinoActionSheet(
      title: widget.title!=null?Text(widget.title):null,
      message: widget.message!=null?Text(widget.message):null,
      cancelButton: CupertinoActionSheetAction(
        onPressed: ()=>Navigator.pop(context),
        child: Text('取消'),
      ),
      actions: actions,
    );
  }
  Widget _buildItem(var e){
    return CupertinoActionSheetAction(
      onPressed: (){
        if(widget.onItemClickListener != null){
          widget.onItemClickListener(widget.list.indexOf(e),e);
        }
      },
      child: Text(e),
    );
  }
}


class MyCupertinoActionSheetAction extends StatelessWidget {
  /// Creates an action for an iOS-style action sheet.
  ///
  /// The [child] and [onPressed] arguments must not be null.
  const MyCupertinoActionSheetAction({
    Key key,
    @required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    @required this.child,
  }) : assert(child != null),
        assert(onPressed != null),
        super(key: key);

  /// The callback that is called when the button is tapped.
  ///
  /// This attribute must not be null.
  final VoidCallback onPressed;

  /// Whether this action is the default choice in the action sheet.
  ///
  /// Default buttons have bold text.
  final bool isDefaultAction;

  /// Whether this action might change or delete data.
  ///
  /// Destructive buttons have red text.
  final bool isDestructiveAction;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      fontFamily: '.SF UI Text',
      inherit: false,
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
    ).copyWith(
      color: isDestructiveAction
          ? CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context)
          : CupertinoTheme.of(context).primaryColor,
    );

    if (isDefaultAction) {
      style = style.copyWith(fontWeight: FontWeight.w600);
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48,
        ),
        child: Semantics(
          button: true,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: DefaultTextStyle(
              style: style,
              child: child,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}