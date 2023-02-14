import 'dart:convert';

import 'package:app/common/theme.dart';
import 'package:app/store/public_chat_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/common/public_chat_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PublicChatView extends StatefulWidget {
  @override
  _PublicChatViewState createState() => _PublicChatViewState();
}

class _PublicChatViewState extends State<PublicChatView> {
  ScrollController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Material(
        color: Color(0xFFF4F2FF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset(IMG.$('公聊大厅'), scale: 2),
              ),
              Expanded(
                child: GetBuilder<PublicChatCtrl>(builder: (it) {
                  final data = it.data;

                  ctrl ??= it.linkedCtrl.addAndGet();

                  return WaterfallFlow.builder(
                    controller: ctrl,
                    gridDelegate: it.delegate,
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    itemBuilder: (_, i) {
                      if (data.isEmpty) return Spacing.w32;

                      return _ItemView(data[i % data.length]);
                    },
                  );
                }),
              ),
            ],
          ),
          onTap: () => Get.to(PublicChatPage()),
        ),
      ),
    );
  }
}

class _ItemView extends StatelessWidget {
  final Map data;

  _ItemView(this.data);

  static const _p = EdgeInsets.all(1);
  static const _ts = TextStyle(fontSize: 12, color: AppPalette.txtPrimary);
  static const _decor = ShapeDecoration(shape: StadiumBorder(), color: Colors.white);

  @override
  Widget build(BuildContext context) {
    String decodeStr = data['data']['content'];
    try {
      decodeStr = utf8.decode(base64Decode(data['data']['content']));
    } catch (e) {
      //todo base64 decode error
    }
    return Container(
      decoration: _decor,
      child: Row(
        children: [
          Padding(padding: _p, child: AvatarView(url: data['member']['avatar'], size: 23)),
          Spacing.w6,
          Text(decodeStr, style: _ts),
          Spacing.w16,
        ],
      ),
    );
  }
}
