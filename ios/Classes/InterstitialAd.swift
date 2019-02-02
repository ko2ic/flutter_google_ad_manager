import GoogleMobileAds

class InterstitialAd: SwiftFlutterGoogleAdManagerPlugin {
    private var interstitialAd: DFPInterstitial?
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func load(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments as! Dictionary<String, Any>
        let isDevelop = argument["isDevelop"] as? Bool ?? false

        if isDevelop {
            interstitialAd = DFPInterstitial(adUnitID: "/6499/example/interstitial")
        } else {
            let adUnitId = argument["adUnitId"] as! String
            interstitialAd = DFPInterstitial(adUnitID: adUnitId)
        }
        interstitialAd!.delegate = self

        let request = DFPRequest()
        interstitialAd!.load(request)
        result(nil)
    }

    private func show(_: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let interstitialAd = interstitialAd else {
            result(FlutterError(code: "program_error", message: "Please call load() method first.", details: nil))
            return
        }

        if interstitialAd.isReady {
            let roolViewControlelr = UIApplication.shared.delegate!.window!!.rootViewController!
            interstitialAd.present(fromRootViewController: roolViewControlelr)
            result(nil)
        } else {
            result(FlutterError(code: "not_loaded_yet", message: "The interstitial wasn't loaded yet.", details: nil))
        }
    }

    private func dispose(_: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}

extension InterstitialAd: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_: DFPInterstitial) {
        channel.invokeMethod("onAdLoaded", arguments: nil)
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_: DFPInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.code])
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_: DFPInterstitial) {
        channel.invokeMethod("onAdOpened", arguments: nil)
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: DFPInterstitial) {
        interstitialAd = DFPInterstitial(adUnitID: ad.adUnitID)
        interstitialAd?.delegate = self
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_: DFPInterstitial) {
        channel.invokeMethod("onAdClosed", arguments: nil)
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_: DFPInterstitial) {
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
