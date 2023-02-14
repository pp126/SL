import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/net/file_api.dart';
import 'package:app/store/oauth_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/tools/dialog.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/customer/app_icon_button.dart';
import 'package:app/widgets/network_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

///图册管理
class MyPhotoPage extends StatefulWidget {
  MyPhotoPage({Key key}) : super(key: key);

  @override
  _MyPhotoPageState createState() => _MyPhotoPageState();
}

class _MyPhotoPageState extends State<MyPhotoPage> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: xAppBar(
        '我的相册',
        action: (isEditing ? '完成' : '编辑').toTxtActionBtn(onPressed: onEditTap),
      ),
      backgroundColor: AppPalette.background,
      body: GetX<OAuthCtrl>(builder: (it) {
        var userInfo = it.info;
        var photos = xMapStr(userInfo, 'privatePhoto', defaultStr: []);
        return _buildPhotoItem(photos);
      }),
    );
  }

  ///编辑
  onEditTap() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  _buildPhotoItem(List photos) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: photos.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return _addView();
          } else {
            final item = photos[i - 1];
            return _itemView(item);
          }
        },
      ),
    );
  }

  _addView() {
    return InkWell(
      onTap: onImagePickerTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xffdcdcdc), width: 0.5),
        ),
        child: Center(
            child: SvgPicture.asset(
          SVG.$('moment/post'),
          fit: BoxFit.fill,
          width: 44,
          height: 44,
        )),
      ),
    );
  }

  onImagePickerTap() async {
    DialogUtils.showPictureDialog(context, callBack: (image) {
      uploadImage(image);
    });
  }

  uploadImage(PickedFile image) {
    simpleSub(
      () async {
        final url = await FileApi.upLoadFile(image, 'avatar/');
        await Api.User.addPhoto(url);
        await OAuthCtrl.obj.fetchInfo();
      },
    );
  }

  _itemView(var data) {
    double size = (Get.width - 16 * 2 - 10 * 2) / 3 - 1;
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NetImage(
            xMapStr(data, 'photoUrl'),
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
          isEditing
              ? Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration:
                        BoxDecoration(color: Color(0xFFF1EEFF), borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Material(
                      color: Colors.transparent,
                      child: AppIconButton(
                          icon: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF7C66FF),
                          ),
                          onPress: () {
                            delImage(data);
                          }),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  delImage(var data) {
    simpleSub(() {
      Api.User.deletePhoto('${data['pid']}').then((value) {
        OAuthCtrl.obj.fetchInfo();
      });
    }, msg: null);
  }
}
