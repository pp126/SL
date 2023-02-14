import 'package:app/tools.dart';
import 'package:app/ui/home/search/search_page.dart';
import 'package:app/ui/home/search/search_page1.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  SearchButton({this.onPressed = _toSearchPage});

  @override
  Widget build(BuildContext context) => '搜索'.toImgActionBtn(onPressed: onPressed);

  static _toSearchPage() => Get.to(SearchPage());
}
