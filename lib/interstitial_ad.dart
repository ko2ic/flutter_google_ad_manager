import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Class to display interstitial ads of Google Ad Manger.
class DFPInterstitialAd {
  static const MethodChannel _channel = const MethodChannel('plugins.ko2ic.com/google_ad_manager/interstitial');

  final bool isDevelop;
  final String adUnitId;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;

  DFPInterstitialAd({
    @required this.isDevelop,
    @required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
  }) {
    _channel.setMethodCallHandler(_handleEvent);
  }

  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
      case 'onAdLoaded':
        this.onAdLoaded();
        break;
      case 'onAdFailedToLoad':
        var errorCode = call.arguments['errorCode'] as int;
        this.onAdFailedToLoad(errorCode);
        break;
      case 'onAdOpened':
        this.onAdOpened();
        break;
      case 'onAdClosed':
        this.onAdClosed();
        break;
      case 'onAdLeftApplication':
        this.onAdLeftApplication();
        break;
    }
    return null;
  }

  /// Load beforehand before displaying.
  Future<void> load() async {
    await _channel.invokeMethod('load', <String, dynamic>{
      'isDevelop': isDevelop,
      'adUnitId': adUnitId,
    });
  }

  /// Display interstitial advertisements.
  Future<void> show() {
    return _channel.invokeMethod('show', <String, dynamic>{});
  }

  /// Dispose interstitial advertisements.
  Future<void> dispose() {
    return _channel.invokeMethod('dispose', <String, dynamic>{});
  }
}
