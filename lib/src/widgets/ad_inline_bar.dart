import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';

class BannerInlineWidget extends StatefulWidget {
  const BannerInlineWidget({Key? key}) : super(key: key);

  @override
  State<BannerInlineWidget> createState() => _BannerInlineWidgetState();
}

class _BannerInlineWidgetState extends State<BannerInlineWidget> {
  // static final _kAdIndex = 4;

  late BannerAd _ad;

  bool _isAdLoaded = false;

  // int _getDestinationItemIndex(int rawIndex) {
  //   if (rawIndex >= _kAdIndex && _isAdLoaded) {
  //     return rawIndex - 1;
  //   }
  //   return rawIndex;
  // }

  @override
  void initState() {
    super.initState();

    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          // ignore: avoid_print
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad.load();
  }

  @override
  void dispose() {
    _ad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_isAdLoaded && index == _kAdIndex) {
    if (_isAdLoaded) {
      return Container(
        child: AdWidget(ad: _ad),
        width: _ad.size.width.toDouble(),
        height: 72.0,
        alignment: Alignment.center,
      );
    } else {
      // final item = widget.entries[_getDestinationItemIndex(index)];

      return Container();
    }
  }
}
