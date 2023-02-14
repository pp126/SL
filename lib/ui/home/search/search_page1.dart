import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/search/search_button.dart';
import 'package:app/ui/home/search/search_record.dart';
import 'package:app/ui/home/search/search_room_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:flutter/material.dart' hide kToolbarHeight;

class SearchPage1 extends StatefulWidget {
  SearchPage1({Key key}) : super(key: key);

  @override
  _SearchPage1State createState() => _SearchPage1State();
}

class _SearchPage1State extends State<SearchPage1> {
  TextEditingController controller = TextEditingController();
  List _historys = [];

  @override
  void initState() {
    super.initState();

    _historys = Storage.read(PrefKey.SearchHistory);
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
        body: NotificationListener(
          onNotification: (_){
            FocusScope.of(context).requestFocus(FocusNode());
            return false;
          },
          child: SingleChildScrollView(
            child: Column(children: [
              _buildHistoryItem(),
              Spacing.h10,
              text != ""?SearchRoomView(text):SizedBox(),
            ]),
          ),
        )
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
    setState(() {});
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
//                Container(
//                  margin: EdgeInsets.only(right: 5),
//                  child: Image.asset(
//                    'images/search/ic_search_history.webp',
//                    width: 19.0,
//                    height: 19.0,
//                  ),
//                ),
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
