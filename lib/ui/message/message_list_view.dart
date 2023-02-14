import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/ui/message/message_item_view.dart';
import 'package:app/ui/message/room_horn_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/future_builder.dart';
import 'package:flutter/material.dart';

class MessageListView extends StatefulWidget {
  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: RoomHornView(),
        ),
        Expanded(
          child: NotifierView(NimHelp.chatNotifier, (data) {
            return RefreshIndicator(
              onRefresh: () async => NimHelp.refreshChatList(),
              child: ListView.separated(
                itemCount: data.length,
                itemBuilder: (_, i) => MessageItemView(data[i]),
                separatorBuilder: (_, __) => Divider(height: 1, indent: 73, endIndent: 15),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class MessageListBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '消息',
                style: TextStyle(fontSize: 16, color: AppPalette.txtDark, fontWeight: fw$SemiBold),
              ),
              'chat/清理'.toSvgActionBtn(onPressed: NimHelp.markAllMessageRead),
            ],
          ),
        ),
        Expanded(child: MessageListView()),
      ],
    );
  }
}
