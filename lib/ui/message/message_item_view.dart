import 'package:app/common/theme.dart';
import 'package:app/nim/nim_help.dart';
import 'package:app/tools.dart';
import 'package:app/tools/time.dart';
import 'package:app/ui/message/chat/chat_page.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:app/ui/message/message_storage_box_view.dart';
import 'package:nim_core/nim_core.dart';

class MessageItemView extends StatelessWidget {
  final NIMMessageData data;
  final VoidCallback dataChange;

  MessageItemView(this.data, {this.dataChange});

  @override
  Widget build(BuildContext context) {
    var user;
    var message;
    int unReadCount = 0;
    if (!data.isStorageBox) {
      user = data.recentSession.userInfo;
      message = data.recentSession.lastMessage;
      unReadCount = data.recentSession.unreadCount;
    }else{
      NIMMessageData msgData = data.unReadList.first;
      message = msgData.recentSession.lastMessage;
      unReadCount = data.unReadCount();
    }

    return InkWell(
        child: Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              data.isStorageBox
                  ? ClipRRect(borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: Image.asset(
                        IMG.$('编组'),
                        width: 48,
                        height: 48,
                      ),
                  )
                  : RectAvatarView(
                      size: 48,
                      url: user?.avatarUrl,
                      uid: int.parse(data.recentSession.sessionId)),
              Spacing.w10,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          data.isStorageBox ? '互动消息' : user?.nickname ?? '',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppPalette.dark,
                              fontWeight: fw$Regular),
                        ),
                        Spacing.exp,
                        Text(
                          TimeUtils.getNewsTimeStr(message.timestamp),
                          style:
                              TextStyle(fontSize: 12, color: AppPalette.hint),
                        ),
                      ],
                    ),
                    Spacing.h10,
                    Row(
                      children: [
                        LimitedBox(
                          maxWidth: Get.width / 2,
                          child: Text(
                             (message as NIMMessage).content,
                            style:
                                TextStyle(fontSize: 12, color: AppPalette.tips),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Spacing.exp,
                        unReadCount > 0
                            ? Container(
                                constraints:
                                    BoxConstraints(maxHeight: 15, minWidth: 15),
                                decoration: ShapeDecoration(
                                    shape: StadiumBorder(),
                                    color: AppPalette.pink),
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                child: Text(
                                  '$unReadCount',
                                  style: TextStyle(
                                    height: 1,
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: fw$SemiBold,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          if (data.isStorageBox) {
            Get.to(MessageStorageBoxView(data.unReadList));
          } else {
            Storage.write(data.recentSession.sessionId.toString(), true);
            if (null != dataChange) {
              dataChange();
            }
            ChatPage.to(user?.nickname ?? '', user?.avatarUrl ?? '',
                data.recentSession.sessionId);
          }
        });
  }
}
