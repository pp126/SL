import 'dart:convert';

import 'package:app/common/cache_manager.dart';
import 'package:app/exception.dart';
import 'package:app/net/api.dart';
import 'package:app/sticker/stickers_rd_view.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class StickerCtrl extends AsyncCtrl<Map<String, StickersInfo>> {
  StickerCtrl() : super({});

  @override
  String get persistent => PrefKey.RoomSticker;

  @override
  Future get api => Api.Room.getRoomExpressionConfig();

  @override
  Map<String, StickersInfo> readCache(String key) {
    final data = Storage.read<Map<String, dynamic>>(key);

    return data?.map((k, v) {
      if (v is StickersInfo) {
        return MapEntry(k, v);
      } else if (v is Map) {
        return MapEntry(k, StickersInfo.fromJson(v));
      } else {
        throw LogicException(-1, '数据错');
      }
    });
  }

  @override
  Map<String, StickersInfo> transform(data) {
    final map = Map.fromIterable(
      data,
      key: (it) => '${it['id']}',
      value: (it) => StickersInfo.fromJson(it),
    );

    try {
      final imgs = Set<String>();

      map.values.forEach((it) {
        imgs.add(it.path);

        final ext = it.ext;

        if (ext != null) {
          final Map res = ext['res'];

          final Iterable<String> urls = res?.values?.cast<String>();

          if (urls != null) {
            imgs.addAll(urls);
          }
        }
      });

      imgs.forEach((it) async => await ImgCacheManager.obj.getSingleFile(it));
    } catch (e) {
      errLog(e);
    }

    return map;
  }

  StickersInfo findById(id) => value[id];

  StickersInfo findByName(name) {
    final data = value.values //
        .firstWhere((it) => it.name == name, orElse: null);

    return data;
  }

  static Widget toView(Map data) {
    final info = StickerCtrl.obj.findByName(data['name']);

    switch (info?.type) {
      case 1:
        return GiftImgState(
          child: NetImage(info.path, fit: BoxFit.contain, optimization: false),
        );
      case 2:
        return StickersRdView(data, info);
      case 3:
        return Stickers3RdViewX(data, info);
        break;
    }

    return SizedBox.shrink();
  }

  static StickerCtrl get obj => Get.find();
}

class RoomStickerCtrl extends AsyncCtrl<List> {
  final int roomID;

  RoomStickerCtrl(this.roomID);

  final _stickerCtrl = StickerCtrl.obj;

  @override
  Future get api => Api.Room.getRoomExpression(roomID);

  static Widget use({@required final Widget Function(List<StickersInfo>) builder}) {
    return GetBuilder<RoomStickerCtrl>(
      builder: (it) {
        return builder(
          it.value //
              .map(it._stickerCtrl.findById)
              .toList(growable: false),
        );
      },
    );
  }
}

class StickersInfo {
  final String name;
  final String path;
  final int type;
  final Map<String, dynamic> ext;

  StickersInfo({this.name, this.path, this.type, this.ext});

  factory StickersInfo.fromJson(Map<String, dynamic> json) {
    final ext = json['ext'];

    return StickersInfo(
      name: json['name'],
      path: json['path'],
      type: json['type'] ?? 0,
      ext: ext == null ? null : jsonDecode(ext),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': this.name,
      'path': this.path,
      'type': this.type,
      if (ext != null) 'ext': jsonEncode(ext),
    };

    return data;
  }

  String getRes(num) => ext['res']['$num'];
}
