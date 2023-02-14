import 'package:app/common/theme.dart';
import 'package:app/net/api.dart';
import 'package:app/tools.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/inputformatter/TextInputFormatter.dart';
import 'package:flutter/material.dart';

class QuitDialog extends StatelessWidget {
  final onTap;
  final bool force;

  QuitDialog({this.onTap, this.force = false});

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
                        height: 275,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(18), topLeft: Radius.circular(18)),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(force ? '申请强制退出公会' : '申请退出公会',
                                style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: FontWeight.w600)),
                            IconButton(
                                icon: Icon(Icons.clear, size: 30, color: Color(0xff252142)),
                                onPressed: () {
                                  Get.back();
                                })
                          ]),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                                force
                                    ? '请注意，强制退会申请发出后，48小时后将自动退会，在此期间可取消强制退会'
                                    : '请注意，退出公会申请发出后，经管理员审核即可退出公会，若管理员24小时内未响应自动驳回，24小时内可取消退出工会',
                                style: TextStyle(color: Color(0xff252142), fontSize: 14)),
                          ),
                          SizedBox(height: 30),
                          Text('确定申请', style: TextStyle(color: Colors.white)).toBtn(40, Color(0xff7C66FF), width: 275,
                              onTap: () {
                            onTap();
                            Get.back();
                          }),
                          SizedBox(height: 30),
                        ]))))));
  }
}

class DissolveDialog extends StatelessWidget {
  final onTap;

  DissolveDialog({this.onTap});

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
                        height: 225,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(18), topLeft: Radius.circular(18)),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('解散公会',
                                style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: FontWeight.w600)),
                            IconButton(
                                icon: Icon(Icons.clear, size: 30, color: Color(0xff252142)),
                                onPressed: () {
                                  Get.back();
                                })
                          ]),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('请注意，公会一旦解散将无法撤回', style: TextStyle(color: Color(0xff252142), fontSize: 14)),
                          ),
                          SizedBox(height: 30),
                          Text('确定解散', style: TextStyle(color: Colors.white)).toBtn(40, Color(0xff7C66FF), width: 275,
                              onTap: () {
                            onTap();
                            Get.back();
                          }),
                          SizedBox(height: 30),
                        ]))))));
  }
}

class ContributionDialog extends StatefulWidget {
  Map data;

  ContributionDialog({this.data});

  @override
  _ContributionDialogState createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<ContributionDialog> {
  TextEditingController editingController = TextEditingController();

  Future<dynamic> getData() {
    return Api.Family.getUserIntegral();
  }

  @override
  Widget build(BuildContext context) {
    String number = editingController.text.trim();
    if (number == '' || num.parse(number).toInt() < 0) {
      number = '0';
    }
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
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
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('贡献积分',
                              style: TextStyle(color: Color(0xff252142), fontSize: 16, fontWeight: FontWeight.w600)),
                          IconButton(
                              icon: Icon(Icons.clear, size: 20, color: Color(0xff252142)),
                              onPressed: () {
                                Get.back();
                              })
                        ]),
                        Spacer(flex: 20),
                        XFutureBuilder(
                            futureBuilder: getData,
                            onData: (data) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child:
                                      Text('当前积分：${data}', style: TextStyle(color: Color(0xff908DA8), fontSize: 14)));
                            }),
                        Spacer(flex: 30),
                        TextField(
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                controller: editingController,
                                inputFormatters: [OnlyInputNumberFormatter()],
                                style: TextStyle(fontSize: 18, height: 1),
                                onChanged: (str) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: AppPalette.hint, fontSize: 18),
                                    border: InputBorder.none))
                            .toWarp(
                                radius: 100, color: Color(0xffF8F7FC), margin: EdgeInsets.symmetric(horizontal: 64)),
                        Spacer(flex: 22),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 73),
                          child: Text('积分由在线时间和每日签到获得，贡献积分是公会升级的唯一途径哦',
                              textAlign: TextAlign.center, style: TextStyle(color: Color(0xff7C66FF), fontSize: 12)),
                        ),
                        Spacer(flex: 10),
                        Text('贡献${number}积分', style: TextStyle(color: Colors.white))
                            .toBtn(40, Color(0xff7C66FF), width: 275, onTap: () {
                          String number = editingController.text.trim();
                          if (number == '') {
                            showToast('请输入贡献值');
                            return;
                          }
                          if (num.parse(number) < 0) {
                            showToast('输入的贡献值必须大于0');
                            return;
                          }
                          simpleSub(Api.Family.devoteIntegral(integral: number), msg: '贡献成功', callback: () {
                            Get.back();
                          });
                        }),
                        Spacer(flex: 30),
                      ]))))),
    );
  }
}
