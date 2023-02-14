import 'package:app/common/theme.dart';
import 'package:app/tools/common_utils.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:app/tools.dart';

class CustomerDialog extends  StatelessWidget{
  final String customerAccount = 'shengnayuyin';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                    onTap: () {},
                    child: Container(
                        height: 310,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(18), topLeft: Radius.circular(18)),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('联系客服',
                                      style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: fw$SemiBold)),
                                  xFlatButton(
                                    40, Colors.transparent,
                                    child:Icon(
                                      Icons.clear,
                                      size: 20,
                                      color: Color(0xff252142),
                                    ),
                                    onTap: Get.back,
                                  ),
                                ]),
                              ),
                              Spacing.h10,
                              Text(
                                '微信客服账号',
                                style: TextStyle(color: AppPalette.hint, fontSize: 16),
                              ),
                              Spacing.exp,
                              Text(
                                customerAccount,
                                style: TextStyle(color: AppPalette.dark, fontSize: 26,fontWeight: fw$SemiBold),
                              ),
                              Spacing.exp,
                              Text(
                                '复制客服微信号码到微信添加即可',
                                style: TextStyle(color: AppPalette.primary, fontSize: 16),
                              ),
                              Spacing.h32,
                              Text('复制账号', style: TextStyle(color: Colors.white, fontSize: 14,height: 1)).toBtn(
                                40,
                                AppPalette.primary,
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                onTap: () => CommonUtils.copyToClipboard(customerAccount),
                              ),
                              Spacing.h32,
                            ]
                        )
                    )
                )
            )
        )
    );
  }
}