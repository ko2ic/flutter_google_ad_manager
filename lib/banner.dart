import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_ad_manager/ad_size.dart';
import 'package:flutter_google_ad_manager/test_devices.dart';

typedef void _DFPBannerViewCreatedCallback(DFPBannerViewController controller);

/// Banner Widget of Google Ad Manger.
class DFPBanner extends StatelessWidget {
  /// If true, develop mode.
  /// It is that adUnitId for test will be used.
  final bool isDevelop;

  /// In the case of the test mode, the class that holds the test device id for display on the real device.
  final TestDevices testDevices;

  final String adUnitId;
  final DFPAdSize adSize;
  final Map<String, dynamic> customTargeting;

  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function(DFPBannerViewController controller) onAdViewCreated;

  /// only android
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;

  DFPBanner({
    @required this.isDevelop,
    this.testDevices,
    @required this.adUnitId,
    @required this.adSize,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    this.onAdViewCreated,
    this.customTargeting,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var width = adSize.width;
    var height = adSize.height;
    if (adSize.width == DFPAdSize.FULL_WIDTH) {
      width = MediaQuery.of(context).size.width;
      if (isPortrait) {
        height = 50;
      } else {
        height = 32;
      }
      // TODO iPad support
    }

//    return OrientationBuilder(builder: (context, Orientation orientation) {
//      var width = adSize.width;
//      var height = adSize.height;
//      if (adSize.width == DFPAdSize.FULL_WIDTH) {
//        width = MediaQuery.of(context).size.width;
//        if (orientation == Orientation.portrait) {
//          height = 50;
//        } else {
//          height = 32;
//        }
//        // TODO iPad support
//      }

    return SizedBox(
      width: width,
      height: height,
      child: _DFPBannerView(
        isDevelop: isDevelop,
        testDevices: testDevices,
        adUnitId: adUnitId,
        adSize: adSize,
        isPortrait: isPortrait,
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: onAdOpened,
        onAdClosed: onAdClosed,
        onAdLeftApplication: onAdLeftApplication,
        onAdViewCreated: onAdViewCreated,
        customTargeting: customTargeting,
        onPlatformCompleted: (DFPBannerViewController controller) {
          controller._init();
          if (onAdViewCreated != null) {
            onAdViewCreated(controller);
          }
        },
      ),
    );
  }
}

class _DFPBannerView extends StatefulWidget {
  final bool isDevelop;
  final TestDevices testDevices;
  final String adUnitId;
  final DFPAdSize adSize;
  final bool isPortrait;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;
  final void Function(DFPBannerViewController controller) onAdViewCreated;
  final _DFPBannerViewCreatedCallback onPlatformCompleted;
  final Map<String, dynamic> customTargeting;

  _DFPBannerView({
    @required this.isDevelop,
    this.testDevices,
    @required this.adUnitId,
    @required this.adSize,
    @required this.isPortrait,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    this.onAdViewCreated,
    this.onPlatformCompleted,
    this.customTargeting,
  });

  @override
  State<StatefulWidget> createState() {
    return _DFPBannerViewState();
  }
}

class _DFPBannerViewState extends State<_DFPBannerView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'plugins.ko2ic.com/google_ad_manager/banner',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: 'plugins.ko2ic.com/google_ad_manager/banner',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    throw UnsupportedError('Only android and ios are supported.');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onPlatformCompleted == null) {
      return;
    }
    widget.onPlatformCompleted(DFPBannerViewController._internal(
      isDevelop: widget.isDevelop,
      testDevices: widget.testDevices,
      adUnitId: widget.adUnitId,
      adSize: widget.adSize,
      isPortrait: widget.isPortrait,
      onAdLoaded: widget.onAdLoaded,
      onAdFailedToLoad: widget.onAdFailedToLoad,
      onAdOpened: widget.onAdOpened,
      onAdClosed: widget.onAdClosed,
      onAdLeftApplication: widget.onAdLeftApplication,
      onAdViewCreated: widget.onAdViewCreated,
      id: id,
      customTargeting: widget.customTargeting,
    ));
  }
}

class DFPBannerViewController {
  final bool isDevelop;
  final TestDevices testDevices;
  final String adUnitId;
  final DFPAdSize adSize;
  final bool isPortrait;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;
  final void Function(DFPBannerViewController controller) onAdViewCreated;
  final Map<String, dynamic> customTargeting;

  DFPBannerViewController._internal({
    @required this.isDevelop,
    this.testDevices,
    @required this.adUnitId,
    @required this.adSize,
    @required this.isPortrait,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    this.onAdViewCreated,
    this.customTargeting,
    int id,
  }) : _channel = MethodChannel('plugins.ko2ic.com/google_ad_manager/banner/$id');

  final MethodChannel _channel;

  Future<void> _init() async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onAdLoaded":
          onAdLoaded();
          break;
        case "onAdFailedToLoad":
          var map = call.arguments.cast<String, int>();
          onAdFailedToLoad(map['errorCode']);
          break;
        case "onAdOpened":
          onAdOpened();
          break;
        case "onAdClosed":
          onAdClosed();
          break;
        case "onAdLeftApplication":
          onAdLeftApplication();
          break;
      }
      return Future.value(null);
    });

    return _load();
  }

  Future<void> reload() async {
    return _load();
  }

  Future<void> _load() {
    return _channel.invokeMethod('load', {
      "isDevelop": this.isDevelop,
      "testDevices": this.testDevices?.values,
      "adUnitId": this.adUnitId,
      "adSizes": [this.adSize.toString()],
      "isPortrait": this.isPortrait,
      "widths": [this.adSize.width],
      "heights": [this.adSize.height],
      "customTargeting": this.customTargeting,
    });
  }
}
