import Flutter
import UIKit

public class SwiftFlutterGoogleAdManagerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.register(BannerViewFactory(messenger: registrar.messenger()), withId: "plugins.ko2ic.com/google_ad_manager/banner")

        let interstitialChannel = FlutterMethodChannel(name: "plugins.ko2ic.com/google_ad_manager/interstitial", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(InterstitialAd(with: registrar, channel: interstitialChannel) as FlutterPlugin, channel: interstitialChannel)

        let rewardedChannel = FlutterMethodChannel(name: "plugins.ko2ic.com/google_ad_manager/rewarded", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(RewardedAd(with: registrar, channel: rewardedChannel) as FlutterPlugin, channel: rewardedChannel)
    }
}
