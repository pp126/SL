
import 'dart:convert';

import 'package:app/store/society_ctrl.dart';

class UserSocietyInfo {
  UserSocietyType type;
  Map data;

  UserSocietyInfo.fromParams({this.type});

  factory UserSocietyInfo(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
      ? new UserSocietyInfo.fromJson(json.decode(jsonStr))
      : new UserSocietyInfo.fromJson(jsonStr);

  UserSocietyInfo.fromJson(jsonRes) {
    int applyType = jsonRes['applyType']??3;
    switch(applyType){///0已加入公会 1申请创建公会中 2申请加入公会中 3未加入公会 4普通申请退出公会中 5强制申请退出公会中
      case 0:
        type = UserSocietyType.inSociety;
        break;
      case 1:
        type = UserSocietyType.applyCreateSociety;
        break;
      case 2:
        type = UserSocietyType.applyJoinSociety;
        break;
      case 3:
        type = UserSocietyType.noSociety;
        break;
      case 4:
        type = UserSocietyType.applyOutSociety;
        break;
      case 5:
        type = UserSocietyType.forceOutSociety;
        break;
      default:
        type = UserSocietyType.noSociety;
        break;
    }
    data = jsonRes;
    data['userSocietyType'] = type;
  }

}