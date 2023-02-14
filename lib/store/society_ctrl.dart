import 'package:app/net/api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum UserSocietyType {
  inSociety,///已加入公会
  applyCreateSociety,///申请创建公会中
  applyJoinSociety,///申请加入公会中
  noSociety,///未加入公会
  applyOutSociety,///普通申请退出公会中
  forceOutSociety,///强制申请退出公会中
}

class SocietyCtrl extends GetxController {
  final info = RxMap();

  static int ROLESTATUS_SHAIKH = 1; //会长
  static int ROLESTATUS_ADMIN = 2; //管理员
  static int ROLESTATUS_MEMBER = 3; //成员

  @override
  void onInit() {
    super.onInit();

    fetchInfo();
  }

  UserSocietyType get type => info != null ? info['userSocietyType'] : UserSocietyType.noSociety;
  ///是否有公会
  bool get isInSociety {
    return type == UserSocietyType.inSociety
        || type == UserSocietyType.applyOutSociety
        || type == UserSocietyType.forceOutSociety;
  }
  ///是否能申请公会
  bool get canApplySociety {
    return type == UserSocietyType.noSociety;
  }
  ///是否在申请该公会
  bool isApplyJoinSociety(var familyId) {
    return type == UserSocietyType.applyJoinSociety
        && (info['familyId'] == familyId);
  }
  ///是否在申请创建公会
  bool get isApplyCreateSociety {
    return type == UserSocietyType.applyCreateSociety;
  }
  ///是否在该公会
  bool isInCurrentSociety(var familyId) {
    return isInSociety
        && (info['familyId'] == familyId);
  }
  ///是否能申请退出公会
  bool canApplyOutSociety() {
    return isSocietyMember() && (info['isForceExitFamily'] != true);
  }
  ///是否能申请强制退出公会
  bool canForceOutSociety() {
    return isSocietyMember() && (info['isForceExitFamily'] == true);
  }
  ///是否是会公成员,会长除外
  bool isSocietyMember() {
    return type == UserSocietyType.inSociety && (isAdmin || isMember);
  }
  Future<Map> fetchInfo() async {
    if (OAuthCtrl.obj.isLogin){
      Map data = await Api.Family.checkFamilyJoin();

      info.value = data;
    }

    return info;
  }
  ///是否有管理权限
  bool get haveAdmin {
    return isInSociety && (isShaikh || isAdmin);
  }
  ///是否是会长
  bool get isShaikh {
    return isInSociety && info['roleStatus'] == ROLESTATUS_SHAIKH;
  }
  ///是否是管理员
  bool get isAdmin {
    return isInSociety && info['roleStatus'] == ROLESTATUS_ADMIN;
  }
  ///是否是会员
  bool get isMember {
    return isInSociety && info['roleStatus'] == ROLESTATUS_MEMBER;
  }
  ///刷新用户公会信息
  doRefresh() async {
    await fetchInfo();
  }

  static Widget society({@required final Widget Function(Map,UserSocietyType) builder}) {
    return GetX<SocietyCtrl>(builder: (it) => builder(it.info,it.type));
  }

  static SocietyCtrl get obj => Get.find();
}
