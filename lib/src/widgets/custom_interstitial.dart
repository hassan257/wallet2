import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../locator.dart';
import '../helpers/ad_helper.dart';
import '../services/navigation_service.dart';

class CustomInterstitial extends StatefulWidget {
  // final Widget child;
  const CustomInterstitial({
    Key? key,
    // required this.child
  }) : super(key: key);

  @override
  State<CustomInterstitial> createState() => _CustomInterstitialState();
}

class _CustomInterstitialState extends State<CustomInterstitial> {
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
              locator<NavigationService>().goBack('/moves');
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          // ignore: avoid_print
          print('Failed to load an interstitial ad: ${err.message}');
          // _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadInterstitialAd();
    return Container(
        // child: widget.child,
        );
  }
}
