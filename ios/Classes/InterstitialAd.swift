import GoogleMobileAds

class InterstitialAd: SwiftFlutterGoogleAdManagerPlugin {
    /// The interstitial ad.
    private var interstitial: GAMInterstitialAd?

    private let channel: FlutterMethodChannel!
    private let exampleInterstitalAd: String = "/6499/example/interstitial"

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

        let adUnitId = argument["adUnitId"] as? String
        loadInterstitial(unitId: isDevelop ? exampleInterstitalAd : adUnitId, result: result)

    }

    private func show(_: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let interstitial = self.interstitial else {
            result(FlutterError.programError)
            return
        }

        guard let rootViewController = UIApplication.rootViewController else {
            result(FlutterError.controllerError)
            return

        }
        interstitial.present(fromRootViewController: rootViewController)
    }

    private func loadInterstitial(unitId: String?, result: @escaping FlutterResult) {
        GAMInterstitialAd.load(
            withAdManagerAdUnitID: unitId ?? "",
            request: GAMRequest()
        ) { (ad, error) in
            if let _ = error {
                result(FlutterError.errorLoadUnitId)
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            result(nil)
        }
    }


    private func dispose(_: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}

extension InterstitialAd: GADFullScreenContentDelegate {
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error)
    {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.localizedDescription])
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }

}
