import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_ad_manager/ad_size.dart';
import 'package:flutter_google_ad_manager/test_devices.dart';

typedef void _DFPBannerViewCreatedCallback(_DFPBannerViewController controller);

/// Banner Widget of Google Ad Manger.
class DFPBanner extends StatelessWidget {

  /// If true, develop mode.
  /// It is that adUnitId for test will be used.
  final bool isDevelop;

  /// In the case of the test mode, the class that holds the test device id for display on the real device.
  final TestDevices testDevices;

  final String adUnitId;
  final DFPAdSize adSize;

  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;

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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: adSize.width,
      height: adSize.height,
      child: _DFPBannerView(
        isDevelop: isDevelop,
        testDevices: testDevices,
        adUnitId: adUnitId,
        adSize: adSize,
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: onAdOpened,
        onAdClosed: onAdClosed,
        onAdLeftApplication: onAdLeftApplication,
        onPlatformCompleted: (_DFPBannerViewController controller) => controller.load(),
      ),
    );
  }
}

class _DFPBannerView extends StatefulWidget {
  final bool isDevelop;
  final TestDevices testDevices;
  final String adUnitId;
  final DFPAdSize adSize;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;
  final _DFPBannerViewCreatedCallback onPlatformCompleted;

  _DFPBannerView({
    @required this.isDevelop,
    this.testDevices,
    @required this.adUnitId,
    @required this.adSize,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    this.onPlatformCompleted,
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
    widget.onPlatformCompleted(_DFPBannerViewController(
      isDevelop: widget.isDevelop,
      adUnitId: widget.adUnitId,
      adSize: widget.adSize,
      onAdLoaded: widget.onAdLoaded,
      onAdFailedToLoad: widget.onAdFailedToLoad,
      onAdOpened: widget.onAdOpened,
      onAdClosed: widget.onAdClosed,
      onAdLeftApplication: widget.onAdLeftApplication,
      id: id,
    ));
  }
}

class _DFPBannerViewController {
  final bool isDevelop;
  final TestDevices testDevices;
  final String adUnitId;
  final DFPAdSize adSize;
  final void Function() onAdLoaded;
  final void Function(int errorCode) onAdFailedToLoad;
  final void Function() onAdOpened;
  final void Function() onAdClosed;
  final void Function() onAdLeftApplication;

  _DFPBannerViewController({
    @required this.isDevelop,
    this.testDevices,
    @required this.adUnitId,
    @required this.adSize,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdLeftApplication,
    int id,
  }) : _channel = new MethodChannel('plugins.ko2ic.com/google_ad_manager/banner/$id');

  final MethodChannel _channel;

  Future<void> load() async {
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
    });

    return _channel.invokeMethod('load', {
      "isDevelop": this.isDevelop,
      "testDevices": this.testDevices?.values,
      "adUnitId": this.adUnitId,
      "adSizes": [this.adSize.toString()],
      "widths": [this.adSize.width],
      "heights": [this.adSize.height],
    });
  }
}
