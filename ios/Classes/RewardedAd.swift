import Flutter
import GoogleMobileAds

class RewardedAd: SwiftFlutterGoogleAdManagerPlugin {
    private let channel: FlutterMethodChannel!

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

        GADRewardBasedVideoAd.sharedInstance().delegate = self
        if isDevelop {
            GADRewardBasedVideoAd.sharedInstance().load(DFPRequest(),
                                                        withAdUnitID: "/6499/example/rewarded-video")
        } else {
            let adUnitId = argument["adUnitId"] as! String
            GADRewardBasedVideoAd.sharedInstance().load(DFPRequest(),
                                                        withAdUnitID: adUnitId)
        }
        result(nil)
    }

    private func show(_: FlutterMethodCall, result: @escaping FlutterResult) {
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            let roolViewControlelr = UIApplication.shared.delegate!.window!!.rootViewController!
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: roolViewControlelr)
            result(nil)
        } else {
            result(FlutterError(code: "not_loaded_yet", message: "The Reward Ads wasn't loaded yet.", details: nil))
        }
    }

    private func dispose(_: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}

extension RewardedAd: GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        channel.invokeMethod("onRewarded", arguments: ["yype": reward.type, "amount": reward.amount])
    }

    func rewardBasedVideoAdDidReceive(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onAdLoaded", arguments: nil)
    }

    func rewardBasedVideoAdDidOpen(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onAdOpened", arguments: nil)
    }

    func rewardBasedVideoAdDidStartPlaying(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onVideoStarted", arguments: nil)
    }

    func rewardBasedVideoAdDidCompletePlaying(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onVideoCompleted", arguments: nil)
    }

    func rewardBasedVideoAdDidClose(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onAdClosed", arguments: nil)
    }

    func rewardBasedVideoAdWillLeaveApplication(_: GADRewardBasedVideoAd) {
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }

    func rewardBasedVideoAd(_: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": (error as NSError).code])
    }
}
