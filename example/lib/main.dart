import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';

import 'banner_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Google Ad Manager Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DFPInterstitialAd _interstitialAd;
  DFPRewardedAd _rewardedAd;
  LifecycleEventHandler _lifecycle;

  @override
  void initState() {
    super.initState();

    _interstitialAd = DFPInterstitialAd(
      isDevelop: true,
      adUnitId: "XXXXXXXX",
      onAdLoaded: () {
        print('interstitialAd onAdLoaded');
      },
      onAdFailedToLoad: (errorCode) {
        print('interstitialAd onAdFailedToLoad: errorCode:$errorCode');
      },
      onAdOpened: () {
        print('interstitialAd onAdOpened');
      },
      onAdClosed: () {
        print('interstitialAd onAdClosed');
        _interstitialAd.load();
      },
      onAdLeftApplication: () {
        print('interstitialAd onAdLeftApplication');
      },
    );
    _interstitialAd.load();

    _rewardedAd = DFPRewardedAd(
      isDevelop: true,
      adUnitId: "XXXXXXX",
      onAdLoaded: () {
        print('rewardedAd onAdLoaded');
      },
      onAdFailedToLoad: (errorCode) {
        print('rewardedAd onAdFailedToLoad: errorCode:$errorCode');
        _showRewardedAdsLoadErrorDialog(context, errorCode);
      },
      onAdOpened: () {
        print('rewardedAd onAdOpened');
      },
      onAdClosed: () {
        print('rewardedAd onAdClosed');
        _rewardedAd.load();
      },
      onAdLeftApplication: () {
        print('rewardedAd onAdLeftApplication');
      },
      onRewarded: (String type, int amount) {
        print('rewardedAd onRewarded: type:$type amount:$amount');
      },
      onVideoStarted: () {
        print('rewardedAd onVideoStarted');
      },
      onVideoCompleted: () {
        print('rewardedAd onVideoCompleted');
      },
    );
    _rewardedAd.load();
    _lifecycle = LifecycleEventHandler(_rewardedAd);
    WidgetsBinding.instance.addObserver(_lifecycle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycle);
    _interstitialAd.dispose();
    _rewardedAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Banners',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            RaisedButton(
              child: Text(DFPAdSize.BANNER.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.BANNER),
                ));
              },
            ),
            RaisedButton(
              child: Text(DFPAdSize.FULL_BANNER.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.FULL_BANNER),
                ));
              },
            ),
            RaisedButton(
              child: Text(DFPAdSize.LARGE_BANNER.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.LARGE_BANNER),
                ));
              },
            ),
            RaisedButton(
              child: Text(DFPAdSize.LEADERBOARD.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.LEADERBOARD),
                ));
              },
            ),
            RaisedButton(
              child: Text(DFPAdSize.MEDIUM_RECTANGLE.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.MEDIUM_RECTANGLE),
                ));
              },
            ),
            RaisedButton(
              child: Text(DFPAdSize.SMART_BANNER.toString()),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerPage(size: DFPAdSize.SMART_BANNER),
                ));
              },
            ),
            Text(
              'Interstitial',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            RaisedButton(
              child: Text('Show Interstitial'),
              onPressed: () {
                _interstitialAd.show();
              },
            ),
            Text(
              'Rewarded',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            RaisedButton(
              child: Text('Show Rewarded'),
              onPressed: () {
                _rewardedAd.show();
              },
            ),
            /*ListView.builder(
            padding: EdgeInsets.all(20.0),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              if (index != 0 && index % 4 == 0) {
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 16.0),
                      child: DFPBanner(
                        isDevelop: true,
                        testDevices: MyTestDevices(),
                        adUnitId: '/XXXXXXXXX/XXXXXXXXX',
                        adSize: DFPAdSize.BANNER,
                        onAdLoaded: () {
                          print('Banner onAdLoaded');
                        },
                        onAdFailedToLoad: (errorCode) {
                          print('Banner onAdFailedToLoad: errorCode:$errorCode');
                        },
                        onAdOpened: () {
                          print('Banner onAdOpened');
                        },
                        onAdClosed: () {
                          print('Banner onAdClosed');
                        },
                        onAdLeftApplication: () {
                          print('Banner onAdLeftApplication');
                        },
                      ),
                    ),
                  ],
                );
              }
              return SizedBox(
                height: 100.0,
                child: Card(
                  child: Center(
                    child: Text('$index'),
                  ),
                ),
              );
            },
          ),*/
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _rewardedAd.show();
          //await interstitialAd.show();
        },
        tooltip: '?',
        child: Icon(Icons.add),
      ),*/
    );
  }

  void _showRewardedAdsLoadErrorDialog(BuildContext context, int errorCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text("Rewarded Ads Load Error"),
            content: Text("error code: $errorCode"),
            actions: <Widget>[
              FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: const Text('Reload'),
                  onPressed: () {
                    _rewardedAd.load();
                    Navigator.pop(context);
                  })
            ],
          ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final DFPRewardedAd rewardedAd;

  LifecycleEventHandler(this.rewardedAd);

  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        await rewardedAd.pause();
        break;
      case AppLifecycleState.suspending:
        break;
      case AppLifecycleState.resumed:
        await rewardedAd.resume();
        break;
    }
  }
}
