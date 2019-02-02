```
import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';

void main() => runApp(MyApp());

class MyTestDevices extends TestDevices {
  static MyTestDevices _instance;

  factory MyTestDevices() {
    if (_instance == null) _instance = new MyTestDevices._internal();
    return _instance;
  }

  MyTestDevices._internal();

  @override
  List<String> get values => List()..add("XXXXXXXX");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  DFPInterstitialAd interstitialAd;
  DFPRewardedAd rewardedAd;
  LifecycleEventHandler _lifecyncle;

  @override
  void initState() {
    super.initState();

    interstitialAd = DFPInterstitialAd(
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
        interstitialAd.load();
      },
      onAdLeftApplication: () {
        print('interstitialAd onAdLeftApplication');
      },
    );
    interstitialAd.load();

    rewardedAd = DFPRewardedAd(
      isDevelop: true,
      adUnitId: "XXXXXXX",
      onAdLoaded: () {
        print('rewardedAd onAdLoaded');
      },
      onAdFailedToLoad: (errorCode) {
        print('rewardedAd onAdFailedToLoad: errorCode:$errorCode');
      },
      onAdOpened: () {
        print('rewardedAd onAdOpened');
      },
      onAdClosed: () {
        print('rewardedAd onAdClosed');
        rewardedAd.load();
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
    rewardedAd.load();
    _lifecyncle = LifecycleEventHandler(rewardedAd);
    WidgetsBinding.instance.addObserver(_lifecyncle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecyncle);
    interstitialAd.dispose();
    rewardedAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
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
                    adUnitId: 'XXXXXXXXX/XXXXXXXXX',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await rewardedAd.show();
          //await interstitialAd.show();
        },
        tooltip: '?',
        child: Icon(Icons.add),
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
```