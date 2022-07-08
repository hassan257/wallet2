import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';

class NativeInlineWidget extends StatefulWidget {
  const NativeInlineWidget({Key? key}) : super(key: key);

  @override
  State<NativeInlineWidget> createState() => _NativeInlineWidgetState();
}

class _NativeInlineWidgetState extends State<NativeInlineWidget> {
  // static final _kAdIndex = 4;
  late NativeAd _ad;
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

    _ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
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
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      return Container(
        child: AdWidget(ad: _ad),
        height: 72.0,
        alignment: Alignment.center,
      );
    } else {
      return Container();
    }
  }
}
