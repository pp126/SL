import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/search/search_button.dart';
import 'package:app/ui/home/search/search_record.dart';
import 'package:app/ui/home/search/search_room_page.dart';
import 'package:app/ui/home/search/search_user_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = TextEditingController();
  List tabs = ['全部', '房间', '用户'];
  List _historys = [];
  final _rommKey = GlobalKey<XFutureBuilderState>();
  final _userKey = GlobalKey<XFutureBuilderState>();

  @override
  void initState() {
    super.initState();
    _historys = Storage.read(PrefKey.SearchHistory);
  }

  Future<List> getRoomData() {
    String text = controller.text.trim();
    return Api.Home.search(text, PageNum(index: 1, size: 3), 2);
  }

  Future<List> getUserData() {
    String text = controller.text.trim();
    return Api.Home.search(text, PageNum(index: 1, size: 3), 1);
  }

  @override
  Widget build(BuildContext context) {
    String text = controller.text.trim();
    return Scaffold(
        appBar: xAppBar(
          titleSearch(controller),
          action: SearchButton(
            onPressed: onSearchTap,
          ),
        ),
        body: text != ""
            ? DefaultTabController(
                length: tabs.length,
                child: Column(
                  children: [
                    SizedBox(height: 26),
                    TabBar(
                      tabs: tabs.map((e) => Text(e)).toList(growable: false),
                      isScrollable: true,
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        children: [
                          //全部
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              XFutureBuilder<List>(
                                key: _rommKey,
                                futureBuilder: getRoomData,
                                emptyType: TipsType.noSearch,
                                onData: (data) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Builder(builder: (context) {
                                        return InkWell(
                                          onTap: () => DefaultTabController.of(context).index = 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('房间搜索结果', style: TextStyle(color: AppPalette.dark, fontSize: 16)),
                                                Text('查看更多', style: TextStyle(color: AppPalette.primary, fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      ...data
                                          .getRange(0, data.length > 3 ? 3 : data.length)
                                          .map((e) => roomItem(e))
                                          .toList(growable: false)
                                    ],
                                  );
                                },
                                tipsSize: 200,
                              ),
                              XFutureBuilder<List>(
                                key: _userKey,
                                futureBuilder: getUserData,
                                emptyType: TipsType.noSearch,
                                onData: (data) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Builder(builder: (context) {
                                        return InkWell(
                                          onTap: () => DefaultTabController.of(context).index = 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('用户搜索结果', style: TextStyle(color: AppPalette.dark, fontSize: 16)),
                                                Text('查看更多', style: TextStyle(color: AppPalette.primary, fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      ...data
                                          .getRange(0, data.length > 3 ? 3 : data.length)
                                          .map((e) => userItem(e))
                                          .toList(growable: false),
                                    ],
                                  );
                                },
                                tipsSize: 200,
                              ),
                            ],
                          ),
                          //房间
                          SearchRoomView(text),
                          //用户
                          SearchUserView(text),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : _buildHistoryItem());
  }

  _buildHistoryItem() {
    return _historys != null && _historys.isNotEmpty
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Center(
                          child: Text(
                            '最近搜索',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      AppIconButton(
                        icon: Icon(Icons.delete),
                        onPress: clearHistory,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 8.0,
                    direction: Axis.horizontal,
                    children: _historys.map((info) {
                      return _buildItem(info ?? '');
                    }).toList(),
                  ),
                )
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildItem(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.text = title;
          onSearchTap();
        });
      },
      child: Container(
        width: title.length * 14.0 + 20,
        height: 30,
        decoration: BoxDecoration(
          color: Color(0xffF4F6F9),
          border: Border.all(color: Color(0xffF4F6F9)),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  onSearchTap() {
    String searchStr = controller.text.trim();
    if (searchStr.isEmpty) {
      showToast('请输入搜索内容');
      return;
    }
    // 触摸收起键盘
    FocusScope.of(context).requestFocus(FocusNode());

    addToHistory(searchStr);

    Bus.send(BUS_SEARCH_ROOM, controller.text);
    Bus.send(BUS_SEARCH_USER, controller.text);
    _rommKey.currentState.doRefresh();
    _userKey.currentState.doRefresh();
    setState(() {});
  }

  ///添加到历史搜索
  addToHistory(String key) {
    if (key == null || key.isEmpty) {
      return;
    }
    bool isIn = false;
    if (_historys != null) {
      for (String sub in _historys) {
        if (key == sub) {
          isIn = true;
          break;
        }
      }
    } else {
      _historys = [];
    }
    if (!isIn) {
      setState(() {
        _historys.insert(0, key);
      });
      Storage.write(PrefKey.SearchHistory, _historys);
    }
  }

  clearHistory() {
    if (_historys != null && _historys.isNotEmpty) {
      setState(() {
        _historys.clear();
        Storage.write(PrefKey.SearchHistory, []);
      });
    }
  }
}
