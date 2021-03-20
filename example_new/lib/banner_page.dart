import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';

import 'my_test_devices.dart';

class BannerPage extends StatefulWidget {
  BannerPage({Key key, @required this.size}) : super(key: key);

  final DFPAdSize size;

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  DFPBannerViewController _bannerViewController;
  String _log = "";

  _updateLog(String s) {
    setState(() {
      _log += s + '\n';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _reload() {
    _bannerViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.size.toString() + ' Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
              child: DFPBanner(
                isDevelop: true,
                testDevices: MyTestDevices(),
                adUnitId: '/XXXXXXXXX/XXXXXXXXX',
                adSize: widget.size,
                onAdViewCreated: (controller) {
                  _bannerViewController = controller;
                },
                onAdLoaded: () {
                  _updateLog('Banner onAdLoaded');
                  print('Banner onAdLoaded');
                },
                onAdFailedToLoad: (errorCode) {
                  _updateLog('Banner onAdFailedToLoad: errorCode:$errorCode');
                  print('Banner onAdFailedToLoad: errorCode:$errorCode');
                },
                onAdOpened: () {
                  _updateLog('Banner onAdOpened');
                  print('Banner onAdOpened');
                },
                onAdClosed: () {
                  _updateLog('Banner onAdClosed');
                  print('Banner onAdClosed');
                },
                onAdLeftApplication: () {
                  _updateLog('Banner onAdLeftApplication');
                  print('Banner onAdLeftApplication');
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.refresh,
        ),
        onPressed: () {
          _reload();
        },
      ),
    );
  }
}
