import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

mixin AutoScrollMixin on GetLifeCycleBase implements EndScrollMixin {
  final autoRx = RxBool(true);

  Future<void> scrollToIndex(int toIndex) async {
    autoRx(false);

    xlog('列表滚动到 -> $toIndex');

    await scroll.scrollTo(
      index: toIndex + 1,
      alignment: 0.5,
      duration: _kDuration,
      curve: Curves.easeOutCubic,
    );
  }
}

mixin EndScrollMixin on GetLifeCycleBase implements GetSingleTickerProviderStateMixin {
  final _kDuration = const Duration(milliseconds: 618);

  final scroll = ItemScrollController();
  final posListener = ItemPositionsListener.create();

  final topLoading = RxBool(false), bottomLoading = RxBool(false);
  var _canFetchTop = false, _canFetchBottom = true;

  Future<bool> onEndScroll();

  Future<bool> onTopScroll();

  void animeToEnd() {
    if (scroll.isAttached) {
      scroll.scrollTo(
        index: 0,
        duration: _kDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void setFetchFlag({bool? fetchTop, bool? fetchBottom}) {
    fetchTop?.let((val) => _canFetchTop = val);
    fetchBottom?.let((val) => _canFetchBottom = val);
  }

  bool onScroll(OverscrollNotification event) {
    if (event.overscroll > 0) {
      _onBottom();
    }
    if (event.overscroll < 0) {
      _onTop();
    }

    return true;
  }

  void _onBottom() async {
    if (_canFetchBottom) {
      _canFetchBottom = false;

      try {
        bottomLoading(true);

        _canFetchBottom = await onEndScroll();
      } catch (e, s) {
        _canFetchBottom = true;

        errLog(e, s: s);
      } finally {
        bottomLoading(false);
      }
    }
  }

  void _onTop() async {
    if (_canFetchTop) {
      _canFetchTop = false;

      try {
        topLoading(true);

        _canFetchTop = await onTopScroll();
      } catch (e, s) {
        _canFetchTop = true;

        errLog(e, s: s);
      } finally {
        topLoading(false);
      }
    }
  }
}
