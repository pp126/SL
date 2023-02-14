import 'package:app/tools.dart';
import 'package:app/widgets/tips_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

abstract class ViewState<T> {
  static final _loading = SizedBox.expand(
    child: SvgPicture.asset(SVG.$('default'), fit: BoxFit.cover),
  );

  static final _emptyView = ([Tuple2<VoidCallback, bool> arg]) => TipsView(arg.item1, tipsType: TipsType.empty,noImage: arg.item2??false,);
  static final _dataLoading = SizedBox.shrink();

  static final providers = [
    Provider<ImgErr>.value(value: ImgErr._(_loading)),
    Provider<ImgLoading>.value(value: ImgLoading._(_loading)),
    Provider<DataEmpty>.value(value: DataEmpty._(_emptyView)),
    Provider<DataLoading>.value(value: DataLoading._(_dataLoading)),
  ];

  ViewState._();

  Widget build([T arg]);
}

abstract class _StateWidget extends StatelessWidget {
  final Widget child;

  _StateWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return providers.isNullOrBlank ? child : MultiProvider(providers: providers, child: child);
  }

  List<Provider> get providers;
}

class ImgLoading extends ViewState {
  final Widget loading;

  ImgLoading._(this.loading) : super._();

  @override
  Widget build([_]) => loading;
}

class ImgErr extends ViewState<Tuple2<Object, StackTrace>> {
  final Widget errView;

  ImgErr._(this.errView) : super._();

  @override
  Widget build([Tuple2<Object, StackTrace> arg]) => errView;
}

typedef Widget BuildEmptyView([Tuple2<VoidCallback, bool> arg]);

class DataEmpty extends ViewState<Tuple2<VoidCallback, bool>> {
  final BuildEmptyView buildEmptyView;

  DataEmpty._(this.buildEmptyView) : super._();

  @override
  Widget build([Tuple2<VoidCallback, bool> arg]) => buildEmptyView(arg);
}

class DataLoading extends ViewState {
  final Widget loading;

  DataLoading._(this.loading) : super._();

  @override
  Widget build([_]) => loading;
}

class ConfigImgState extends _StateWidget {
  final Widget child;
  final Widget errView;
  final Widget loading;

  ConfigImgState({this.child, this.errView, this.loading});

  @override
  List<Provider> get providers => [
        if (!errView.isNull) Provider<ImgErr>.value(value: ImgErr._(errView)),
        if (!loading.isNull) Provider<ImgLoading>.value(value: ImgLoading._(loading)),
      ];
}

class ConfigListState extends _StateWidget {
  final Widget child;
  final Widget loading;
  final BuildEmptyView buildEmptyView;

  ConfigListState({this.child, this.loading, this.buildEmptyView});

  @override
  List<Provider> get providers => [
        if (!buildEmptyView.isNull) Provider<DataEmpty>.value(value: DataEmpty._(buildEmptyView)),
        if (!loading.isNull) Provider<DataLoading>.value(value: DataLoading._(loading)),
      ];
}

extension ViewStateContext on BuildContext {
  Widget state<T extends ViewState>([arg]) => Provider.of<T>(this, listen: false).build(arg);
}

class GiftImgState extends ConfigImgState {
  static const _loading = SizedBox.shrink();
  static const _errView = isRelease //
      ? SizedBox.shrink()
      : Icon(Icons.bug_report, color: Colors.red);

  GiftImgState({@required Widget child}) : super(loading: _loading, errView: _errView, child: child);
}
