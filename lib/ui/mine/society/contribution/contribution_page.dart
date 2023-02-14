import 'dart:ui';

import 'package:app/common/bus_key.dart';
import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/ui/mine/society/dialog/dialogs.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/level_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContributionPage extends StatefulWidget {
  final Map data;

  ContributionPage(this.data);

  @override
  _ContributionPageState createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  Map data;

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  refresh() {
    Bus.send(BUS_SOCIETY_CONTRIBUTION_PAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: xAppBar(
          '贡献榜',
        ),
        body: Stack(children: [
          contributionMember(),
          Positioned(
              left: 50,
              right: 50,
              bottom: 44,
              child: Text('去贡献', style: TextStyle(color: Colors.white, fontSize: 14)).toBtn(40, Color(0xff7C66FF),
                  onTap: () {
                context.showDownDialog(ContributionDialog(data: data)).then((value) => refresh());
              }))
        ]));
  }

  contributionMember() {
    return ContributionMemberList(widget.data);
  }
}

class ContributionMemberList extends StatefulWidget {
  Map data;

  ContributionMemberList(this.data);

  @override
  _ContributionMemberListState createState() => _ContributionMemberListState();
}

class _ContributionMemberListState extends NetPageList<dynamic, ContributionMemberList> {
  int partakeNum = 0;

  @override
  void initState() {
    super.initState();
    Bus.sub(BUS_SOCIETY_CONTRIBUTION_PAGE, (data) {
      doRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Bus.fire(BUS_SOCIETY_ADMIN_PAGE);
  }

  @override
  Future fetchPage(PageNum page) {
    return Api.Family.getContributionListV2(
        familyId: widget.data['familyId'], current: page.index.toString(), pageSize: page.size.toString());
  }

  @override
  List transform(data) {
    partakeNum = data['partakeNum'];
    return super.transform(data['list']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20, right: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('参与成员', style: TextStyle(color: AppPalette.dark, fontSize: 16, fontWeight: FontWeight.w600)),
            Text('$partakeNum', style: TextStyle(color: AppPalette.hint, fontSize: 16, fontWeight: FontWeight.w600))
          ])),
      Expanded(child: super.build(context))
    ]);
  }

  @override
  Widget itemBuilder(BuildContext context, dynamic item, int index) {
    SvgPicture crown;
    switch (index) {
      case 0:
      case 1:
      case 2:
        crown = SvgPicture.asset(
          SVG.$('home/rank/crown_${index + 1}'),
          width: 26,
          height: 26,
        );
        break;
    }
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 30),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 40,
          child: Center(
            child:
                crown != null ? crown : Text(index.toString(), style: TextStyle(color: AppPalette.tips, fontSize: 16)),
          ),
        ),
        Spacing.w8,
        RectAvatarView(size: 48, url: item['avatar'], uid: item['uid']),
        Spacing.w8,
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(item['nike'], style: TextStyle(color: AppPalette.dark, fontSize: 14)),
              Row(children: [
                SvgPicture.asset(SVG.$('mine/性别_${item['gender'] == 0 ? '2' : '1'}')),
                Spacing.w8,
                WealthIcon(data: item)
              ]),
            ])),
        Spacing.w4,
        Text('${item['familyIntegralDay']}', style: TextStyle(color: AppPalette.primary, fontSize: 14)),
      ]),
    );
  }
}
