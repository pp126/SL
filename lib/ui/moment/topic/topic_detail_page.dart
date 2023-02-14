import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/moment_item_view.dart';
import 'package:app/ui/moment/topic/topic_title_item.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

///话题广场
class TopicDetailPage extends StatefulWidget {
  final topicData;

  TopicDetailPage({Key key, this.topicData}) : super(key: key);

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('话题详情'),
      backgroundColor: AppPalette.background,
      body: _TopicDetail(
        topicData: widget.topicData,
      ),
    );
  }
}

class _TopicDetail extends StatefulWidget {
  final topicData;

  _TopicDetail({Key key, this.topicData}) : super(key: key);

  @override
  _TopicDetailState createState() => new _TopicDetailState();
}

class _TopicDetailState extends NetPageList<Map, _TopicDetail> {
  @override
  BaseConfig initListConfig() {
    return ListConfig(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
//      header: _buildHeaderItem(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfigListState(
      buildEmptyView: ([Tuple2<VoidCallback, bool> arg]) => TipsView(
        arg.item1,
        tipsType: TipsType.empty,
        noImage: true,
        message: '暂时没有相关动态哦！',
      ),
      child: super.build(context),
    );
  }

  @override
  Widget transformWidget(BuildContext context, Widget child) => SingleChildScrollView(
        child: Column(
          children: [_buildHeaderItem(), child],
        ),
      );

  _buildHeaderItem() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: AspectRatio(
                  aspectRatio: 303 / 100,
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetImage('${xMapStr(widget.topicData, 'coverImgUrl', defaultStr: '')}', fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 20,
                child: TopicTitleItem(
                  data: widget.topicData,
                  canJumpDetail: false,
                ),
              )
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            '${xMapStr(widget.topicData, 'subjectDetail', defaultStr: '')}',
            style: TextStyle(fontSize: 14, color: AppPalette.dark),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  @override
  Future fetchPage(PageNum page) =>
      Api.Moment.momentList(subjectId: xMapStr(widget.topicData, 'subjectId'), page: page);

  @override
  Widget itemBuilder(BuildContext context, Map item, int index) {
    return MomentItemView(data: item);
  }
}
