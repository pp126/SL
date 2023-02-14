// import 'package:app/net/api.dart';
// import 'package:app/net/api_help.dart';
// import 'package:app/widgets/waiting_dialog.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
//
// import '../tools.dart';
//
// ///内购，暂时只有苹果内购
// abstract class InAppState<T extends StatefulWidget> extends State<T> {
//   StreamSubscription _purchaseUpdatedSubscription;
//   StreamSubscription _purchaseErrorSubscription;
//   StreamSubscription _connectionSubscription;
//   List<IAPItem> items = [];///商品列表
//   List<PurchasedItem> purchases = [];
//   Map orders = {};
//   String currentRecordId;
//
//   @override
//   void initState() {
//     super.initState();
//
//     orders = Storage.read(PrefKey.InAppRecords)??{};
//
//     initPlatformState();
//   }
//
//   @override
//   void dispose() {
//     endConnect();
//     super.dispose();
//   }
//
//   ///刷新数据，子类重写
//   doRefresh(){
//
//   }
//
//   ///初始化
//   Future<void> initPlatformState() async {
//     if(Platform.isIOS){
//       // prepare
//       var result = await FlutterInappPurchase.instance.initConnection;
//       print('result: $result');
//
//       _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
//         print('connected: $connected');
//         WaitingCtrl.obj.hidden();
//       });
//
//       _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
//
//         try {
//           print('purchase-updated: $productItem');
//           ///保存交易数据
//           saveRecord(productItem);
//           ///校验交易
//           checkPurchase(productItem,refresh: true);
//         } finally {
//           WaitingCtrl.obj.hidden();
//         }
//       });
//
//       _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
//         print('purchase-error: $purchaseError');
//         WaitingCtrl.obj.hidden();
//       });
//
//       ///若有正在未停止的交易的，校验一下
//       getPurchases(check: true);
//     }
//   }
//   ///关闭
//   Future<void> endConnect() async {
//     if(Platform.isIOS) {
//       await FlutterInappPurchase.instance.endConnection;
//       if (_purchaseUpdatedSubscription != null) {
//         _purchaseUpdatedSubscription.cancel();
//         _purchaseUpdatedSubscription = null;
//       }
//       if (_purchaseErrorSubscription != null) {
//         _purchaseErrorSubscription.cancel();
//         _purchaseErrorSubscription = null;
//       }
//       if (_connectionSubscription != null) {
//         _connectionSubscription.cancel();
//         _connectionSubscription = null;
//       }
//     }
//   }
//   ///申请内购
//   Future<void> requestPurchase(String chargeProdId) async {
//     final ctrl = WaitingCtrl.obj;
//     print('chargeProdId=$chargeProdId');
//
//     try {
//       ctrl.show();
//       ///向后台下单，获取recordId;
//       var data = await Api.User.orderInApp(
//         chargeProdId,
//       );
//       currentRecordId = data["recordId"];
//       print('recordId=$currentRecordId');
//
//       ///获取苹果产品信息
//       String productId = await getProduct(chargeProdId);
//       print('productId=$productId');
//
//       ///向苹果申请内内购
//       await FlutterInappPurchase.instance.requestPurchase(productId);
//       ctrl.hidden();
//     } finally {
//       ctrl.hidden();
//     }
//   }
//   ///校验内购结果
//   Future<void> checkPurchase(PurchasedItem productItem,{bool refresh = false}) async {
//     final ctrl = WaitingCtrl.obj;
//     try {
//       ctrl.show();
//
//       ///向后台校验;
//       String orderId = orders[productItem.transactionId];
//       print('length==${productItem.transactionReceipt.length}');
//       print('transactionReceipt==${productItem.transactionReceipt}');
//       Api.User.checkOrder(
//         receiptData:productItem.transactionReceipt,
//         trancid: productItem.transactionId,
//         chargeRecordId: orderId,
//       ).then((value) => null).whenComplete((){
//         print('whenComplete');
//         if(refresh) {
//           ///刷新数据
//           doRefresh();
//         }
//         ///关闭交易
//         FlutterInappPurchase.instance.finishTransactionIOS(productItem.transactionId);
//       });
//
//       ctrl.hidden();
//     } finally {
//       ctrl.hidden();
//     }
//   }
//   ///获取内购商品列表
//   Future<String> getProduct(String chargeProdId) async {
//     List<IAPItem> _items = await FlutterInappPurchase.instance.getProducts([chargeProdId]);
//     for (var item in _items) {
//       if(item.productId == chargeProdId){
//         return item.productId;
//       }
//     }
//     return chargeProdId;
//   }
//
//   ///获取用户进行的所有购买
//   Future getPurchases({bool check = false}) async {
//     List<PurchasedItem> _items =
//     await FlutterInappPurchase.instance.getAvailablePurchases();
//     for (var item in _items) {
//       print('length==${item.transactionReceipt.length}');
//       print('${item.toString()}');
//       if(check){
//         checkPurchase(item,refresh: true);
//       }
//       this.purchases.add(item);
//     }
//   }
//   ///获取历史购买商品列表
//   Future getPurchaseHistory() async {
//     List<PurchasedItem> _items = await FlutterInappPurchase.instance.getPurchaseHistory();
//     for (var item in _items) {
//       print('${item.toString()}');
//       print('length==${item.transactionReceipt.length}');
//       this.purchases.add(item);
//     }
//   }
//
//   saveRecord(PurchasedItem productItem){
//     orders[productItem.transactionId] = currentRecordId;
//     Storage.write(PrefKey.SearchHistory, orders);
//   }
// }