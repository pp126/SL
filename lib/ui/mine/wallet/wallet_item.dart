import 'package:app/common/theme.dart';
import 'package:app/store/wallet_ctrl.dart';
import 'package:flutter/material.dart';

class WalletItem extends StatefulWidget {
  final bool showGold;
  final bool showGift;

  WalletItem({this.showGold = true, this.showGift = true});

  @override
  _WalletItemState createState() => _WalletItemState();
}

class _WalletItemState extends State<WalletItem> {
  @override
  Widget build(BuildContext context) {
    return _buildWalletItem();
  }

  _buildWalletItem() {
    return WalletCtrl.useAllGold(builder: (_, gold, diamond) {
      return Container(
        alignment: Alignment.center,
        height: 124,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showGold) goldView('我的海星', '$gold'),
            if (widget.showGift) goldView('我的珍珠', '$diamond'),
          ],
        ),
      );
    });
  }

  Widget goldView(
    String title,
    String gold,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$gold',
            style: TextStyle(color: AppPalette.primary, fontSize: 30, fontWeight: fw$SemiBold),
          ),
          Text(
            title,
            style: TextStyle(color: AppPalette.dark, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
