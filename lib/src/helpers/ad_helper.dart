import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-6473425324446369/3265704191";
    } else if (Platform.isIOS) {
      // return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
      throw UnsupportedError("Unsupported platform");
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-6473425324446369/7013377518";
    } else if (Platform.isIOS) {
      // return "<YOUR_IOS_NATIVE_AD_UNIT_ID>";
      throw UnsupportedError("Unsupported platform");
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
