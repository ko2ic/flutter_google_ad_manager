import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_ad_manager/ad_size.dart';
import 'package:flutter_google_ad_manager/test_devices.dart';

/// Banner Widget of Google Ad Manger.
class DFPBanner extends StatefulWidget {
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
    Key key,
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
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DFPBannerState();
  }
}

class DFPBannerState extends State<DFPBanner> {
  DFPBannerViewController _controller;

  bool _isPortrait;

  @override
  Widget build(BuildContext context) {
    _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    Size size;
    if (widget.adSize.width == DFPAdSize.FULL_WIDTH) {
      final width = MediaQuery.of(context).size.width;
      if (_isPortrait) {
        size = Size(width, 50);
      } else {
        size = Size(width, 32);
      }
      // TODO iPad support
    } else {
      size = Size(widget.adSize.width, widget.adSize.height);
    }

    return SizedBox(
      width: size.width,
      height: size.height,
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
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
    //throw UnsupportedError('Only android and ios are supported.');
    return null;
  }

  void _onPlatformViewCreated(int id) {
    _controller = DFPBannerViewController._internal(
      isDevelop: widget.isDevelop,
      testDevices: widget.testDevices,
      adUnitId: widget.adUnitId,
      adSize: widget.adSize,
      isPortrait: _isPortrait ?? true,
      onAdLoaded: widget.onAdLoaded,
      onAdFailedToLoad: widget.onAdFailedToLoad,
      onAdOpened: widget.onAdOpened,
      onAdClosed: widget.onAdClosed,
      onAdLeftApplication: widget.onAdLeftApplication,
      onAdViewCreated: widget.onAdViewCreated,
      id: id,
      customTargeting: widget.customTargeting,
    );
    _controller._init();

    if (widget.onAdViewCreated != null) {
      widget.onAdViewCreated(_controller);
    }
  }

  Future<void> reload() {
    return _controller?.reload();
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

  Future<void> _init() {
    _channel.setMethodCallHandler(_handler);
    return _load();
  }

  Future<void> _handler(MethodCall call) {
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
  }

  Future<void> reload() {
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
