import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Class to display Rewarded Video Ads of Google Ad Manger.
class DFPRewardedAd {
  static const MethodChannel _channel = const MethodChannel('plugins.ko2ic.com/google_ad_manager/rewarded');

  final bool isDevelop;
  final String adUnitId;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;
  final void Function(String type, int amount) onRewarded;
  final void Function() onVideoStarted;
  final void Function() onVideoCompleted;

  DFPRewardedAd({
    @required this.isDevelop,
    @required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    this.onRewarded,
    this.onVideoStarted,
    this.onVideoCompleted,
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
      case 'onRewarded':
        var type = call.arguments['type'] as String;
        var amount = call.arguments['amount'] as int;
        this.onRewarded(type, amount);
        break;
      case 'onVideoStarted':
        this.onVideoStarted();
        break;
      case 'onVideoCompleted':
        this.onVideoCompleted();
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

  /// Display Rewarded Video advertisements.
  Future<void> show() {
    return _channel.invokeMethod('show', <String, dynamic>{});
  }

  /// Pause Rewarded Video advertisements.
  /// only android.
  Future<void> pause() {
    return _channel.invokeMethod('pause', <String, dynamic>{});
  }

  /// Resume Rewarded Video advertisements.
  /// only android.
  Future<void> resume() {
    return _channel.invokeMethod('resume', <String, dynamic>{});
  }

  /// Dispose Rewarded Video advertisements.
  Future<void> dispose() {
    return _channel.invokeMethod('dispose', <String, dynamic>{});
  }
}
