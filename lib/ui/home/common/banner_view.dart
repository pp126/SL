import 'package:app/net/api.dart';
import 'package:app/store/async_ctrl.dart';
import 'package:app/tools.dart';
import 'package:app/ui/home/act/home_act_view.dart';
import 'package:app/widgets.dart';
import 'package:app/widgets/customer/app_swiper_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class BannerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerCtrl>(builder: (it) {
      final data = it.value;

      Widget child;

      if (isEmpty(data)) {
        xlog('Banner is Empty');
      } else if (data.length == 1) {
        child = itemBuilder(data.single);
      } else {
        child = Swiper(
          loop: true,
          autoplay: true,
          curve: Curves.ease,
          autoplayDelay: 3000,
          itemCount: data.length,
          itemBuilder: (_, i) => itemBuilder(data[i]),
          pagination: SwiperPagination(
            alignment: Alignment.bottomRight,
            builder: APPDotSwiperPaginationBuilder(),
            margin: const EdgeInsets.only(right: 20, bottom: 10),
          ),
        );
      }

      return AspectRatio(aspectRatio: 343 / 100, child: child);
    });
  }

  Widget itemBuilder(item) {
    return GestureDetector(
      onTap: () => Get.to(HomeActPage()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.margin_h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: NetImage(item['bannerPic'], fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class BannerCtrl extends AsyncCtrl<List> {
  @override
  Future get api => Api.Home.getIndexTopBanner();

  @override
  String get persistent => PrefKey.BannerData;
}
