import 'dart:async';

import 'package:meta/meta.dart';

mixin ListResource {
  Future fetch();

  List transform(data) => data;
}

mixin PageResource on ListResource {
  Future fetchPage(PageNum page);
}

@protected
class PageCtrl {
  PageNum page;
  bool hasMore, loadMore;

  PageCtrl({int index = 1, int size = 20, this.hasMore = true, this.loadMore = false})
      : page = PageNum(index: index, size: size);

  rest() {
    page.index = 1;
    hasMore = true;
    loadMore = false;
  }
}

class PageNum {
  final int size;
  int index;

  PageNum({this.index = 1, this.size = 20});

  int get start => (index - 1) * size;

  int get limit => size - 1;

  Map<String, dynamic> operator +(Map<String, dynamic> other) {
    other['pageNum'] = index;
    other['pageSize'] = size;

    return other;
  }
}
