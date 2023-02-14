import 'dart:io';

import 'package:app/common/theme.dart';
import 'package:app/event/moment_event.dart';
import 'package:app/model/ParamInfo.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/tools.dart';
import 'package:app/ui/moment/pass_moment_item.dart';
import 'package:app/ui/moment/topic/topic_page.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ImageParamInfo {
  File imagePath;
  String url;
  String icon;

  ImageParamInfo({this.imagePath, this.url, this.icon});
}

abstract class PostPage extends StatelessWidget {
  static to({Map momentData, ParamInfo typeInfo}) {
    if (momentData != null) {
      Get.to(_PassPostPage(momentData));
    } else if (typeInfo != null) {
      Get.to(_NewPostPage(typeInfo));
    }
  }

  PostPage._();

  final ctrl = TextEditingController();
  final selectTopic = RxMap({});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '发布动态',
        action: '发布'.toTxtActionBtn(onPressed: _onSub),
      ),
      backgroundColor: AppPalette.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInputView(),
            body(),
            _buildHotView(),
          ],
        ),
      ),
    );
  }

  _buildInputView() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 150,
      ),
      margin: EdgeInsets.only(top: 15),
      child: TextField(
        controller: ctrl,
        maxLines: 5,
        maxLength: 200,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "说说此刻的想法吧！",
          hintStyle: TextStyle(color: AppPalette.hint, fontSize: 14),
          contentPadding: EdgeInsets.only(left: 16, right: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  _buildHotView() {
    return Row(
      children: [
        SvgPicture.asset(SVG.$('moment/talk')),
        Spacing.w2,
        Obx(
          () => Text(
            xMapStr(selectTopic, 'subjectName', defaultStr: '选择热门话题'),
            style: TextStyle(fontSize: 14, color: AppPalette.dark),
          ),
        ),
        Spacing.exp,
        Icon(Icons.keyboard_arrow_right, size: 24),
      ],
    ).toBtn(
      60,
      Colors.white,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 20),
      radius: 12,
      onTap: enterSelectTopic,
    );
  }

  ///去选择话题
  enterSelectTopic() async {
    final result = await Get.to(TopicPage(
        selectStatus: true,
      selectTopic: selectTopic,
    ));

    if (result is Map) {
      selectTopic.value = result;
    }
  }

  Widget body();

  Future api(String content, int subjectId);

  void _onSub() {
    final content = ctrl.text;

    if (content.isEmpty) {
      showToast('请填写此刻的想法');
      return;
    }
//    if (content.trim().isEmpty) {
//      showToast('不能只输入空格！');
//      return;
//    }

    simpleSub(
      api(content, xMapStr(selectTopic, 'subjectId', defaultStr: null)),
      msg: '发布成功',
      callback: () {
        Bus.fire(MomentEvent());

        Get.back();
      },
    );
  }
}

class _NewPostPage extends PostPage {
  final ParamInfo typeInfo;
  final images = RxList(<ImageParamInfo>[]);

  _NewPostPage(this.typeInfo) : super._();

  final _photoLimit = 9;

  @override
  Future api(String content, int subjectId) => Api.Moment.postMoment(
        forwardDynamicId: null,
        dynamicType: typeInfo.type,
        content: content,
        attachmentUrl: images.map((it) => it.url).join(','),
        subjectId: subjectId,
        isPass: false,
      );

  @override
  Widget body() {
    return Column(
      children: [
        getReturnPhotoWidget(),
        _buildMenuView(),
      ],
    );
  }

  Widget getReturnPhotoWidget() {
    double size = (Get.width - 16*2 - 10*3)/4-1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Obx(() {
        return GridView.count(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          children: [
            for (final it in images)
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8, right: 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(it.imagePath, fit: BoxFit.cover,width: size,height: size,),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    width: 32,
                    height: 32,
                    child: InkResponse(
                      onTap: () => images.remove(it),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(color: AppPalette.txtWhite, shape: BoxShape.circle),
                          width: 20,
                          height: 20,
                          child: Icon(Icons.close, size: 14, color: AppPalette.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }

  _buildMenuView() {
    final data = [
      ParamInfo(
        name: '拍照',
        iconPath: SVG.$('post/photo'),
        onPress: () => onImagePickerTap(true),
      ),
      ParamInfo(
        name: '相册',
        iconPath: SVG.$('post/album'),
        onPress: () => onImagePickerTap(false),
      ),
    ];

    final children = data.map((e) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: e.onPress,
          child: Container(
            child: Column(
              children: [
                SvgPicture.asset(e.iconPath, width: 60, height: 60),
                Spacing.h8,
                Text(
                  e.name,
                  style: TextStyle(fontSize: 14, color: AppPalette.tips),
                )
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Container(
      margin: EdgeInsets.only(top: 15, left: 16, right: 16),
      child: Row(children: children),
    );
  }

  void onImagePickerTap(bool photo) {
    if (images.length >= _photoLimit) {
      showToast('最多只能上传$_photoLimit张图片!');

      return;
    }

    imagePicker(
      uploadImage,
      max: 1280,
      source: photo ? ImageSource.camera : ImageSource.gallery,
    );
  }

  uploadImage(PickedFile image) {
    simpleSub(
      () async {
        final value = await FileApi.upLoadFile(image, 'post/');

        images.add(ImageParamInfo(imagePath: File(image.path), url: value));
      },
      msg: null,
    );
  }
}

class _PassPostPage extends PostPage {
  final Map momentData;

  _PassPostPage(this.momentData) : super._();

  @override
  Future api(String content, int subjectId) => Api.Moment.postMoment(
        dynamicType: null,
        attachmentUrl: null,
        content: content,
        subjectId: subjectId,
        forwardDynamicId: xMapStr(xMapStr(momentData, 'userDynamic'), 'dynamicMsgId'),
        isPass: true,
      );

  @override
  Widget body() => PassMomentItem(data: momentData);
}
