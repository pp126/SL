import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:app/common/theme.dart';
import 'package:app/rtc/rtc_help.dart';
import 'package:app/tools.dart';
import 'package:app/ui/mine/avatar_view.dart';
import 'package:app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class MusicInfo {
  final String id;
  final String title;
  final String artist;
  final int duration;
  final String path;

  MusicInfo({this.id, this.title, this.artist, this.duration, this.path});

  String get displayName => '${title ?? ''}-${artist ?? '未知艺术家'}';
}

class MusicCtrl extends GetxService {
  final list = RxList<MusicInfo>([]);
  final state = RxBool(true);
  final select = Rx<MusicInfo>(null);

  @override
  void onInit() {
    super.onInit();

    // FlutterAudioQuery().getSongs(sortType: SongSortType.ALPHABETIC_COMPOSER).then((it) {
    //   final data = it.where(
    //     (it) {
    //       final filter = [
    //         !it.isMusic,
    //         it.isAlarm,
    //         it.isNotification,
    //         it.isPodcast,
    //         it.isRingtone,
    //         it.album == 'call_rec',
    //         it.album == 'sound_recorder',
    //       ];
    //
    //       return filter.every((it) => !it);
    //     },
    //   ).map(
    //     (it) => MusicInfo(
    //       id: it.id,
    //       title: it.title,
    //       path: it.filePath,
    //       artist: it.artist,
    //       duration: int.tryParse(it.duration) ?? 0,
    //     ),
    //   );
    //
    //   select.value = data.first;
    //
    //   list.addAll(data);
    // });
  }
}

class MusicDialog extends StatefulWidget {
  @override
  _MusicDialogState createState() => _MusicDialogState();
}

class _MusicDialogState extends State<MusicDialog> with TickerProviderStateMixin {
  MusicCtrl get musicCtrl => Get.find();
  final ctrl = PageController(initialPage: 1);

  AnimationController animeCtrl;

  @override
  void initState() {
    super.initState();

    animeCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 6180),
    );

    _doAnime(AudioMixingStateCode it) {
      switch (it) {
        case AudioMixingStateCode.Playing:
          animeCtrl.repeat();
          break;
        default:
          animeCtrl.stop();
      }
    }

    ever(RtcHelp.bgmState, _doAnime);

    _doAnime(RtcHelp.bgmState.value);

    autoTips(PrefKey.tips('音乐播放器'), () async {
      await Get.alertDialog('左划"音量控制"，右划"播放列表"');

      ctrl.animateToPage(
        0,
        duration: kTabScrollDuration,
        curve: Curves.decelerate,
      );
    });
  }

  @override
  void dispose() {
    animeCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width * 0.8;

    return Center(
      child: Card(
        child: Container(
          width: w,
          height: w / 0.618,
          child: Column(
            children: [
              $MusicView(),
              Expanded(
                child: PageView(
                  controller: ctrl,
                  children: [_MusicMixinView(), _PlayListView()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget $MusicView() {
    return Material(
      color: AppPalette.txtWhite,
      child: Container(
        height: 72,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Obx(() {
          final select = musicCtrl.select.value;

          return Row(
            children: [
              RotationTransition(
                turns: animeCtrl,
                child: AvatarView(
                  size: 56,
                  side: BorderSide(color: Colors.white),
                  url: null,
                ),
              ),
              Spacing.w8,
              Expanded(child: Text(select?.displayName ?? '--', softWrap: false)),
              Obx(() {
                IconData icon;
                VoidCallback onTap;

                switch (RtcHelp.bgmState.value) {
                  case AudioMixingStateCode.Playing:
                    icon = Icons.pause_circle_outline;
                    onTap = RtcHelp.pauseBGM;

                    break;
                  case AudioMixingStateCode.Paused:
                    icon = Icons.play_circle_outline;
                    onTap = RtcHelp.resumeBGM;

                    break;
                  case AudioMixingStateCode.Stopped:
                    icon = Icons.play_circle_outline;
                    onTap = () {
                      if (select != null) RtcHelp.playBGM(select.path);
                    };

                    break;
                  case AudioMixingStateCode.Failed:
                    icon = Icons.play_circle_outline;
                    onTap = () {
                      showToast('资源异常，播放失败');
                    };

                    break;
                }

                return InkResponse(
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Icon(icon),
                  ),
                  onTap: onTap,
                );
              }),
              InkResponse(
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(Icons.queue_music_rounded),
                ),
                onTap: () => Get.to(MusicManagerPage(), preventDuplicates: false),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PlayListView extends GetWidget<MusicCtrl> {
  final _format = DateFormat('mm:ss');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.list;

      return ListView.separated(
        itemCount: data.length,
        itemBuilder: (_, i) => createItem(data[i], i),
        separatorBuilder: (_, __) => Divider(),
      );
    });
  }

  Widget createItem(MusicInfo item, int i) {
    //TODO Duration格式化
    final time = DateTime.fromMillisecondsSinceEpoch(item.duration);

    return Obx(() {
      final select = controller.select.value?.id;

      return ListTile(
        selected: item.id == select,
        subtitle: Text('${item.artist}'),
        trailing: Text(_format.format(time)),
        title: Text('${i + 1}.${item.title}'),
        onTap: () {
          controller.select.value = item;

          RtcHelp.playBGM(item.path);
        },
      );
    });
  }
}

class _MusicMixinView extends StatelessWidget {
  final data = [
    Tuple2('麦克风音量', RtcHelp.micVol),
    Tuple2('本地背景音乐音量', RtcHelp.bgmLocalVol),
    Tuple2('远端背景音乐音量', RtcHelp.bgmPushVol),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      itemBuilder: (_, i) => createItem(data[i]),
      separatorBuilder: (_, __) => Divider(),
    );
  }

  Widget createItem(Tuple2<String, RxDouble> item) {
    return ListTile(
      title: Text(item.item1),
      subtitle: Obx(() {
        final value = item.item2.value;

        return Slider(
          min: 0,
          max: 100,
          divisions: 100,
          value: value,
          label: value.toStringAsFixed(0),
          onChanged: (v) => item.item2.value = v,
        );
      }),
    );
  }
}

class MusicManagerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar('音乐管理'),
    );
  }
}
