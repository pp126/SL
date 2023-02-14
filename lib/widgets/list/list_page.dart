import 'dart:async';
import 'dart:developer';

import 'package:app/exception.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/resource.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

export 'resource.dart';

abstract class BaseList<T, W extends StatefulWidget> extends State<W> {
  List<T> _data;
  BaseConfig _config;

  List get listData => _data;

  @override
  void initState() {
    super.initState();

    _config = initListConfig();
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) => _data.isNull ? context.state<DataLoading>() : _createDataView();

  Widget _createDataView() => transformWidget(context, _config._createBy(_data.length, _itemBuilder));

  Widget _itemBuilder(BuildContext context, int index) => itemBuilder(context, _data[index], index);

  BaseConfig initListConfig();

  Widget itemBuilder(BuildContext context, T item, int index);

  ///pageview之外的view添加
  Widget transformWidget(BuildContext context, Widget child);

  void delItem(T item) {
    Timer.run(() {
      if (_data.remove(item)) {
        if (mounted) setState(() {});
      } else {
        assert(false, '删除失败');
      }
    });
  }
}

abstract class NetList<T, W extends StatefulWidget> extends BaseList<T, W> with ListResource {
  final indGK = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    Timer.run(doRefresh);
  }

  @override
  BaseConfig initListConfig() => ListConfig();

  doRefresh() => indGK.currentState?.show();

  @override
  @mustCallSuper
  List<T> transform(data) => (data as List)?.cast();

  Future<void> _fetch() async {
    _data ??= [];

    try {
      final list = transform(await fetch());

      if (list is List<T>) {
        _data
          ..clear()
          ..addAll(list);
      }
    } on NotDataException {
      _data.clear();

      log('-> NotData');
    } catch (e, s) {
      errLog(e, s: s);

      showToast('$e');
    }

    _setState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(key: indGK, onRefresh: _fetch, child: super.build(context));

  @override
  Widget _createDataView() {
    return _data.isNullOrBlank //
        ? transformWidget(context, context.state<DataEmpty>(Tuple2(doRefresh, _config.noTipsImage ?? false)))
        : super._createDataView();
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => child;
}

abstract class NetPageList<T, W extends StatefulWidget> extends NetList<T, W> with PageResource, ScrollMixin {
  final _page = PageCtrl();

  @override
  Widget _createDataView() => $Listener(super._createDataView());

  @override
  void onEnd() => _fetchPage();

  _fetchPage() async {
    if (!_page.hasMore || _page.loadMore) return;

    try {
      _page.loadMore = true;

      _data += transform(await fetchPage(_page.page));

      _setState();
    } on NotDataException {
      _page.hasMore = false;
    } catch (e, s) {
      errLog(e, s: s);
    } finally {
      _page.loadMore = false;
    }
  }

  next() async {
    await _fetchPage();
  }

  @override
  @mustCallSuper
  List<T> transform(data) {
    final list = super.transform(data) ?? [];

    if (isEmpty(list)) {
      _page.hasMore = false;
    } else {
      _page.page.index++;
    }

    return list;
  }

  @override
  Future fetch() {
    _page.rest();

    return fetchPage(_page.page);
  }
}

abstract class ScrollMixin {
  $Listener(Widget child) {
    return NotificationListener(
      child: child,
      onNotification: _onNotification,
    );
  }

  bool _onNotification(ScrollUpdateNotification e) {
    if (e.depth == 0 && e.scrollDelta > 0) {
      final metrics = e.metrics;
      if (metrics is ScrollMetrics) {
        final max = metrics.maxScrollExtent;
        final height = metrics.viewportDimension;
        final curr = metrics.pixels;
        if ((curr + height) > max) onEnd();
      }
    }

    return false;
  }

  void onEnd();
}

typedef Widget ListWrap(Widget listView);

abstract class BaseConfig {
  final bool shrinkWrap;
  final EdgeInsets padding;
  final ScrollPhysics physics;
  final bool hideFocus; //滚动隐藏键盘
  final bool noTipsImage;

  BaseConfig({this.shrinkWrap, this.padding, this.physics, this.hideFocus = false, this.noTipsImage});

  Widget _createBy(int count, IndexedWidgetBuilder builder);
}

class ListConfig extends BaseConfig {
  final double itemExtent;
  final Widget divider;

  ListConfig({
    this.itemExtent,
    this.divider,
    ListWrap listWrap,
    bool shrinkWrap = false,
    EdgeInsets padding,
    ScrollPhysics physics = const AlwaysScrollableScrollPhysics(),
    bool noTipsImage,
  }) : super(shrinkWrap: shrinkWrap, padding: padding, physics: physics, noTipsImage: noTipsImage);

  @override
  Widget _createBy(int count, IndexedWidgetBuilder builder) {
    Widget listView;

    if (divider == null) {
      listView = ListView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        itemExtent: itemExtent,
        itemCount: count,
        itemBuilder: builder,
        keyboardDismissBehavior: hideFocus //
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
      );
    } else {
      listView = ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        itemCount: count,
        itemBuilder: builder,
        separatorBuilder: (_, __) => divider,
        keyboardDismissBehavior: hideFocus //
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
      );
    }

    return listView;
  }
}

class GridConfig extends BaseConfig {
  final SliverGridDelegate gridDelegate;

  GridConfig({
    @required this.gridDelegate,
    Widget emptyView,
    ListWrap listWrap,
    bool shrinkWrap = false,
    EdgeInsets padding,
    ScrollPhysics physics = const AlwaysScrollableScrollPhysics(),
    bool noTipsImage,
  }) : super(shrinkWrap: shrinkWrap, padding: padding, physics: physics, noTipsImage: noTipsImage);

  @override
  Widget _createBy(int count, IndexedWidgetBuilder builder) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: count,
      itemBuilder: builder,
      keyboardDismissBehavior: hideFocus //
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
    );
  }
}

class WrapConfig extends BaseConfig {
  final SliverGridDelegate gridDelegate;
  final BuildContext context;

  WrapConfig({
    @required this.gridDelegate,
    @required this.context,
    Widget emptyView,
    ListWrap listWrap,
    bool shrinkWrap = false,
    EdgeInsets padding,
    ScrollPhysics physics = const AlwaysScrollableScrollPhysics(),
    bool noTipsImage,
  }) : super(shrinkWrap: shrinkWrap, padding: padding, physics: physics, noTipsImage: noTipsImage);

  @override
  Widget _createBy(int count, IndexedWidgetBuilder builder) {
    // return GridView.builder(
    //   shrinkWrap: shrinkWrap,
    //   physics: physics,
    //   padding: padding,
    //   gridDelegate: gridDelegate,
    //   itemCount: count,
    //   itemBuilder: builder,
    //   keyboardDismissBehavior: hideFocus //
    //       ? ScrollViewKeyboardDismissBehavior.onDrag
    //       : ScrollViewKeyboardDismissBehavior.manual,
    // );

    return Wrap(
      children: List.generate(count, (index){
        return builder(context,index);
      }).toList(),
    );
  }
}
