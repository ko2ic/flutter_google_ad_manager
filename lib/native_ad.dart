import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum DFPNativeAdParameterType { image, text }

class DFPNativeAd {
  static const MethodChannel _channel =
      const MethodChannel('plugins.ko2ic.com/google_ad_manager/native');

  final bool isDevelop;
  final String adUnitId;
  final String templateId;

  final Map<String, dynamic> customTargeting;

  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;
  final void Function(String type, int amount) onRewarded;
  final void Function() onVideoStarted;
  final void Function() onVideoCompleted;

  DFPNativeAd({
    @required this.isDevelop,
    @required this.adUnitId,
    @required this.templateId,
    this.customTargeting,
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
      'templateId': templateId,
      'customTargeting': customTargeting,
    });
  }

  // Request any parameter from Native Custom Template
  Future<String> getParameter(
      DFPNativeAdParameterType type, String parameter) async {
    String typeValue;
    switch (type) {
      case DFPNativeAdParameterType.image:
        typeValue = "image";
        break;
      case DFPNativeAdParameterType.text:
        typeValue = "text";
        break;
    }
    return await _channel.invokeMethod('getParameter', <String, dynamic>{
      'type': typeValue,
      'parameter': parameter,
    });
  }

  // Perform the default click action of the asset also recording the click
  Future<void> performClickAction(String parameter) async {
    await _channel.invokeMethod(
        'performClick', <String, dynamic>{'parameter': parameter});
  }

  // Dispose Native advertisements.
   Future<void> dispose() {
     return _channel.invokeMethod('dispose', <String, dynamic>{});
   }
}
