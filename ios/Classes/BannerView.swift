import Foundation
import GoogleMobileAds

class BannerView: NSObject, FlutterPlatformView {
    private var container: UIView!
    private let channel: FlutterMethodChannel!

    init(frame: CGRect, viewIdentifier viewId: Int64, messenger: FlutterBinaryMessenger) {
        container = UIView(frame: frame)
        channel = FlutterMethodChannel(name: "plugins.ko2ic.com/google_ad_manager/banner/\(viewId)", binaryMessenger: messenger)

        super.init()

        container.backgroundColor = UIColor.clear
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handle(call, result: result)
        })
    }

    func view() -> UIView {
        return container
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            load(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func load(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments as! Dictionary<String, Any>
        let isDevelop = argument["isDevelop"] as? Bool ?? false
        let testDevices = argument["testDevices"] as? [String]
        let adSizesArgument = argument["adSizes"] as! [String]
        let widthsArgument = argument["widths"] as! [Int]
        let heightsArgument = argument["heights"] as! [Int]
        let adSize = convertToAdSizes(adSizesArgument, widths: widthsArgument, heights: heightsArgument, result: result).first!

        let adUnitId = argument["adUnitId"] as! String

        let bannerView = DFPBannerView(adSize: adSize)
        let request = DFPRequest()
        if isDevelop {
            bannerView.adUnitID = "/6499/example/banner"
            if let testDevices = testDevices {
                request.testDevices = testDevices
            }
        } else {
            bannerView.adUnitID = adUnitId
        }

        bannerView.delegate = self

        bannerView.rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!

        addBannerViewToView(bannerView)

        bannerView.load(request)
        result(nil)
    }

    private func addBannerViewToView(_ bannerView: DFPBannerView) {
        container.addSubview(bannerView)

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraints([NSLayoutConstraint(item: bannerView,
                                                     attribute: .centerX,
                                                     relatedBy: .equal,
                                                     toItem: container,
                                                     attribute: .centerX,
                                                     multiplier: 1,
                                                     constant: 0),
                                  NSLayoutConstraint(item: bannerView,
                                                     attribute: .centerY,
                                                     relatedBy: .equal,
                                                     toItem: container,
                                                     attribute: .centerY,
                                                     multiplier: 1,
                                                     constant: 0)])
    }

    private func convertToAdSizes(_ names: [String], widths: [Int], heights: [Int], result: @escaping FlutterResult) -> [GADAdSize] {
        return names.enumerated().map { (index: Int, name: String) -> GADAdSize in
            switch name {
            case "BANNER":
                return kGADAdSizeBanner
            case "FULL_BANNER":
                return kGADAdSizeFullBanner
            case "LARGE_BANNER":
                return kGADAdSizeLargeBanner
            case "LEADERBOARD":
                return kGADAdSizeLeaderboard
            case "MEDIUM_RECTANGLE":
                return kGADAdSizeMediumRectangle
            case "SMART_BANNER":
                return kGADAdSizeSmartBannerPortrait // TODO: Portrait or Landscape
            case "CUSTOM":
                return GADAdSizeFromCGSize(CGSize(width: widths[index], height: heights[index]))
            default:
                result(FlutterError(code: "illegal_argument", message: "\(name) is unsupported.", details: nil))
                return GADAdSizeFromCGSize(CGSize(width: 0, height: 0))
            }
        }
    }
}

extension BannerView: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_: DFPBannerView) {
        channel.invokeMethod("onAdLoaded", arguments: nil)
    }

    /// Tells the delegate an ad request failed.
    func adView(_: DFPBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        container = nil
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.code])
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_: DFPBannerView) {
        print(adViewWillPresentScreen) // TODO:
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_: DFPBannerView) {
        print(adViewWillDismissScreen) // TODO:
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_: DFPBannerView) {
        print(adViewDidDismissScreen) // TODO:
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_: DFPBannerView) {
        channel.invokeMethod("onAdOpened", arguments: nil)
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
