import Flutter
import GoogleMobileAds

class RewardedAd: SwiftFlutterGoogleAdManagerPlugin {
    private let channel: FlutterMethodChannel!

    /// The reward-based video ad.
    weak var rewardedAd: GADRewardedAd?

    private let exampleReward = "/6499/example/rewarded-video"

    public init(with _: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handle(call, result: result)
        })
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            load(call, result: result)
        case "show":
            show(call, result: result)
        case "dispose":
            dispose(call, result: result)
        case "pause":
            break
        case "resume":
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func load(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments as! Dictionary<String, Any>
        let isDevelop = argument["isDevelop"] as? Bool ?? false


        let unitId: String? = isDevelop ? exampleReward : argument["adUnitId"] as? String
        GADRewardedAd.load(
            withAdUnitID: unitId ?? "", request: GAMRequest()
        ) { (ad, error) in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            print("Loading Succeeded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
        result(nil)
    }


    private func show(_: FlutterMethodCall, result: @escaping FlutterResult) {

        guard let ad = rewardedAd else {
            result(FlutterError.notLoad)
            return
        }

        guard let rootViewController = UIApplication.rootViewController else {
            result(FlutterError.controllerError)
            return
        }

        ad.present(fromRootViewController: rootViewController) { [weak self] in
            guard let self = self else { return }

            let reward = ad.adReward
            self.channel.invokeMethod("onRewarded", arguments: ["type": reward.type, "amount": reward.amount])
            result(nil)
        }
    }

    private func dispose(_: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}



extension RewardedAd: GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // TODO:
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//       TODO:
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": (error as NSError).code])
    }

}


//
//extension RewardedAd: GADRewardBasedVideoAdDelegate {
//    func rewardBasedVideoAd(_: GADRewardBasedVideoAd,
//                            didRewardUserWith reward: GADAdReward) {
//        channel.invokeMethod("onRewarded", arguments: ["yype": reward.type, "amount": reward.amount])
//    }
//
//    func rewardBasedVideoAdDidReceive(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onAdLoaded", arguments: nil)
//    }
//
//    func rewardBasedVideoAdDidOpen(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onAdOpened", arguments: nil)
//    }
//
//    func rewardBasedVideoAdDidStartPlaying(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onVideoStarted", arguments: nil)
//    }
//
//    func rewardBasedVideoAdDidCompletePlaying(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onVideoCompleted", arguments: nil)
//    }
//
//    func rewardBasedVideoAdDidClose(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onAdClosed", arguments: nil)
//    }
//
//    func rewardBasedVideoAdWillLeaveApplication(_: GADRewardBasedVideoAd) {
//        channel.invokeMethod("onAdLeftApplication", arguments: nil)
//    }
//
//    func rewardBasedVideoAd(_: GADRewardBasedVideoAd,
//                            didFailToLoadWithError error: Error) {
//        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": (error as NSError).code])
//    }
//}
