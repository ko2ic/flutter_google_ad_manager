# flutter_google_ad_manager

Flutter plugin for Google Ad Manager(DoubleClick for Publishers).

<img src="https://raw.githubusercontent.com/wiki/ko2ic/flutter_google_ad_manager/images/sample.gif" width="300px"/>


## Getting Started

### ios

Add ```io.flutter.embedded_views_preview``` in info.plist

```
<key>io.flutter.embedded_views_preview</key>
<true/>
```

Follow any additional instructions found here

[Google Ad Manager Getting Started Guide](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start#update_your_infoplist)

### Android

Add ```com.google.android.gms.ads.AD_MANAGER_APP``` in AndroidManifest.xml

```
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.AD_MANAGER_APP"
            android:value="true"/>
    </application>
</manifest>
```
Follow any additional instructions found here

[Google Ad Manager Getting Started Guide](https://developers.google.com/ad-manager/mobile-ads-sdk/android/quick-start#update_your_androidmanifestxml)

# Banner Ads

Just write the ```DFPBanner``` widget in your favorite place.

```dart
DFPBanner(
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
```

## About testDevices

If you set ```isDevelop``` to true, the test adUnitId will be used.   
( If set false, the described ```adUnitId``` is used.)    
Google Ad Manger needs to register ```testDevices``` in case of actual devices.

With this plug-in, you can create the following class and set it to testDevices of DFPBanner.

```dart
class MyTestDevices extends TestDevices {
  static MyTestDevices _instance;

  factory MyTestDevices() {
    if (_instance == null) _instance = new MyTestDevices._internal();
    return _instance;
  }

  MyTestDevices._internal();

  @override
  List<String> get values => List()..add("XXXXXXXX"); // Set here.
}
```

```
DFPBanner(
  testDevices: MyTestDevices(),
```

## About adSize

```DFPAdSize``` is available. This is the same size as that of android.

* BANNER
* FULL_BANNER
* LARGE_BANNER
* LEADERBOARD
* MEDIUM_RECTANGLE
* SMART_BANNER (Only Portrait)

Other custom is also available.

```const DFPAdSize.custom({double width, double height})```.

## About EventListener

Event listeners are also available.   
However, ios does __not__ work. (I am conducting an investigation, but I do not know yet.)
If you really want to use it, you can use listener by bringing Plugin source to your application.

# Interstitial Ads


```load``` it and call the ```show``` method at the desired timing.

```dart
DFPInterstitialAd _interstitialAd;

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
      interstitialAd.load();
    },
    onAdLeftApplication: () {
      print('interstitialAd onAdLeftApplication');
    },
  );
  _interstitialAd.load();
}

@override
void dispose() {
  _interstitialAd.dispose();
  super.dispose();
}
```

```
await interstitialAd.show();
```

## About isDevelop

If you set ```isDevelop``` to true, the test adUnitId will be used.   
( If set false, the described ```adUnitId``` is used.)  

## About EventListener

It is similar to the above Banner.   
It does __not__ work on ios.   

Because of this, it can not be reloaded after closing, so it can not be displayed twice on the same screen.

# Rewarded Ads

firstly ```load``` it and call the ```show``` method at the desired timing.

```dart
DFPRewardedAd _rewardedAd;
LifecycleEventHandler _lifecycle;

@override
void initState() {
  super.initState();
  _rewardedAd = DFPRewardedAd(
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
  _rewardedAd.dispose();
  super.dispose();
}
```

```dart
await _rewardedAd.show();
```

It is necessary to call it when ```resumed``` and ```paused```, respectively.
For that, please implement WidgetsBindingObserver.

```dart
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

## About isDevelop

If you set ```isDevelop``` to true, the test adUnitId will be used.   
( If set false, the described ```adUnitId``` is used.)  

## About EventListener

Event listeners are also available.   
__This also works with ios and android__.

# Native Ads

Not implemented.   
I am glad if someone will give me a pull request.
