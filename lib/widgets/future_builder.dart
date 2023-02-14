import 'package:app/common/theme.dart';
import 'package:app/exception.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/tips_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef Widget OnLoading();
typedef Widget OnEmpty({msg});
typedef Widget OnError(msg,{type});
typedef Widget OnData<T>(T data);

typedef AsyncFutureBuilder<T> = Future<T> Function();

class XFutureBuilder<T> extends StatefulWidget {
  final AsyncFutureBuilder<T> futureBuilder;
  final OnData<T> onData;
  final OnError onError;
  final OnEmpty onEmpty;
  final OnLoading onLoading;
  final ValueChanged onComplete;
  final TipsType emptyType;///空状态类型
  final bool noTipsImage;
  final double tipsSize;///OnEmpty、OnError、OnLoading视图图片大小
  final bool sliverToBox;///OnEmpty、OnError、OnLoading转SliverToBoxAdapter


  const XFutureBuilder({
    @required this.futureBuilder,
    this.onData,
    this.onError,
    this.onEmpty,
    this.onLoading,
    this.onComplete,
    this.emptyType,
    this.tipsSize,
    this.sliverToBox = false,
    this.noTipsImage = true,
    Key key,
  }):super(key:key);

  @override
  XFutureBuilderState<T> createState() => XFutureBuilderState<T>();
}

class XFutureBuilderState<T> extends State<XFutureBuilder<T>> {
  Future<T> future;
  @override
  void initState() {
    // TODO: implement initState
    doRefresh(refresh: false);
    super.initState();
  }

  @override
  void didUpdateWidget(XFutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureBuilder != widget.futureBuilder) {
      doRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: builder,
    );
  }

  Widget builder(BuildContext context, AsyncSnapshot<T> snapshot) {
    final T data = snapshot.data;

    if (data == null) {
      switch (snapshot.connectionState) {
        case ConnectionState.done:
          {
            if (widget.onComplete != null) {
              widget.onComplete(data);
            }
            return _onError(snapshot.error);
          }
          break;
        default:
          return _onLoading();
      }
    } else {
      if(widget.onComplete != null){
        widget.onComplete(data);
      }

      if((data is Map && data.isEmpty) || (data is List && data.isEmpty)){
        return _onEmpty();
      }else if (widget.onData != null) {
        return widget.onData(data);
      }
    }

    return SizedBox.shrink();
  }

  Widget _onError(err) {
    var msg;
    TipsType type = TipsType.fail;

    if (err is LogicException) {
      msg = err.msg;
    } else if (err is NetException) {
      msg = err.msg;
      type = TipsType.noNetwork;
    } else if (err is Map) {
      msg = err['msg'];
    } else if (err is String) {
      msg = err;
    }
    var child = widget.onError!=null?widget.onError(msg,type:type):TipsView(
      doRefresh,
      message: msg,
      tipsType: type,
      imageSize: widget.tipsSize,
      noImage: widget.noTipsImage,
    );
    return sliverToBox(child);
  }

  Widget _onEmpty({msg}) {
    var child = widget.onEmpty!=null?widget.onEmpty():TipsView(
      doRefresh,
      message: msg,
      tipsType: widget.emptyType,
      imageSize: widget.tipsSize,
      noImage: widget.noTipsImage,
    );
    return sliverToBox(child);
  }

  Widget _onLoading(){
    var child = widget.onLoading!=null?widget.onLoading():Center(
        child: CircularProgressIndicator(),
    );
    return sliverToBox(child);
  }
  sliverToBox(var child){
    return widget.sliverToBox?SliverToBoxAdapter(
      child: child,
    ):child;
  }
  ///刷新数据,外面调用：_key.currentState.doRefresh();
  doRefresh({refresh = true}){
    if(widget.futureBuilder != null){
      future = widget.futureBuilder();
      if(refresh && mounted){
        setState(() {

        });
      }
    }
  }
}

class NotifierView<T> extends StatelessWidget {
  final ValueListenable<T> notifier;
  final OnData<T> onData;

  NotifierView(this.notifier, this.onData);

  @override
  Widget build(BuildContext context) {
    return ValueListenableProvider.value(
      value: notifier,
      child: Consumer<T>(builder: (_, T v, __) => onData(v)),
    );
  }
}
