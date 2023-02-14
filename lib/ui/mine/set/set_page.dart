import 'dart:io';

import 'package:app/common/theme.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/ui/mine/presentation/presentation_page.dart';
import 'package:app/ui/mine/safe/safe_page.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../room_black_list_page.dart';

class SetPage extends StatefulWidget {
  @override
  _SetPageState createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('设置'),
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16, top: 10),
        child: Column(
          children: <Widget>[
            _ActionView(),
            SizedBox(
              height: 40,
            ),
            Text(
              '退出登录',
              style: TextStyle(color: AppPalette.pink, fontSize: 14),
            ).toBtn(
              40,
              Color(0xffFFE9ED),
              margin: EdgeInsets.symmetric(horizontal: 16),
              onTap: OAuthCtrl.obj.logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionView extends StatefulWidget {
  @override
  __ActionViewState createState() => __ActionViewState();
}

class __ActionViewState extends State<_ActionView> {
  final _divider = PreferredSize(
    child: Divider(height: 1, indent: 32, endIndent: 32),
    preferredSize: Size.fromHeight(1),
  );

  String version;
  String _localCache = '0.0M';

  @override
  void initState() {
    super.initState();

    initParams();
  }

  initParams() async {
    version = appInfo.version;
    loadCache();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tipDatas = {
      '关于我们': version,
      '清理缓存数据': _localCache,
    };
    var data = Platform.isIOS
        ? [
            [
              '账户与安全',
              '黑名单管理',
            ],
            ['给喵喵语音评分', '清理缓存数据', '关于我们'],
            [],
          ]
        : [
            [
              '账户与安全',
              '黑名单管理',
            ],
            ['清理缓存数据', '关于我们'],
            [],
          ];
    final items = data.map((it) {
      final items = it
          .map((it) => TableItem(title: it, tips: tipDatas[it], onTap: () => onItemClick(it)))
          .toList(growable: false);

      return TableGroup(
        items,
        margin: EdgeInsets.symmetric(horizontal: 16),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 14, color: AppPalette.dark),
        createDivider: () => _divider,
      );
    }).toList(growable: false);

    return TableView(items, spacing: 10, itemExtent: 64);
  }

  void onItemClick(String item) {
    switch (item) {
      case '清理缓存数据':
        delCacheTap();
        break;
      case '关于我们':
        Get.to(PresentationPage());
        break;
      case '黑名单管理':
        Get.to(RoomBlackListPage());
        break;
      case '账户与安全':
        Get.to(SafePage());
        break;
      case '给喵喵语音评分':
        CommonUtils.launchURL(
          'itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=$xAppId&pageNumber=0&sortOrdering=2&mt=8',
        );
        break;
    }
  }

  ///获取本地缓存
  ///加载缓存
  Future<Null> loadCache() async {
    Directory tempDir = await getTemporaryDirectory();
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    print('临时目录大小: ' + value.toString());
    setState(() {
      _localCache = _renderSize(value); // _cacheSizeStr用来存储大小的值
    });
  }

  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        if (children != null)
          for (final FileSystemEntity child in children) total += await _getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    if (0 == value) {
      return '0.0M';
    }
    List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  delCacheTap() {
    DialogUtils.showCustomerOptionDialog(context, title: '确认清除缓存？', optionCallback: () {
      _clearCache();
    });
  }

  ///清险缓存
  void _clearCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      //删除缓存目录
      await delDir(tempDir);
      showToast('清理成功，已为您节省$_localCache空间');
      await loadCache();
    } catch (e) {
      print(e);
      showToast('清除缓存失败');
    } finally {
      //此处隐藏加载loading
    }
  }

  ///递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await delDir(child);
        }
      }
      await file.delete();
    } catch (e) {
      print(e);
    }
  }
}
