import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/ui/moment/topic/topic_item.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/list/list_page.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';

///话题广场
class TopicPage extends StatefulWidget {
  final bool selectStatus;
  final selectTopic;

  ///是否处于选择状态
  TopicPage({Key key, this.selectStatus = false,this.selectTopic}) : super(key: key);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  var selectTopic;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.selectTopic != null){
      selectTopic = widget.selectTopic;
    }
  }
  @override
  Widget build(BuildContext context) {
    bool select = selectTopic != null;
    return Scaffold(
      appBar: xAppBar('话题广场',
          action: widget.selectStatus
              ? [
            select
                ?'确定'.toTxtActionBtn(onPressed: () {
              Navigator.pop(context, selectTopic);
            }): SizedBox(),
            Spacing.w16,
          ]
              : null),
      backgroundColor: AppPalette.background,
      body: TopicListView(
        selectStatus: widget.selectStatus,
        selectTopic: selectTopic,
        selectCallBack: (e) {
          setState(() {
            selectTopic = e;
          });
        },
      ),
    );
  }
}

class TopicListView extends StatefulWidget {
  final bool selectStatus;

  ///是否处于选择状态
  final selectTopic;
  final ValueChanged selectCallBack;

  TopicListView({this.selectStatus = false, this.selectCallBack, this.selectTopic});

  @override
  _TopicListViewState createState() => _TopicListViewState();
}

class _TopicListViewState extends NetPageList<Map, TopicListView> {
  @override
  Future fetchPage(PageNum page) => Api.Moment.topicList(page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return TopicItemView(
      data: item,
      selectStatus: widget.selectStatus,
      selectTopic: widget.selectTopic,
      selectCallBack: (e) {
        if (widget.selectCallBack != null) {
          widget.selectCallBack(
            item,
          );
        }
      },
    );
  }
}
