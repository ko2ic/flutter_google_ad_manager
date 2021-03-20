import Foundation
import GoogleMobileAds

class BannerView: NSObject, FlutterPlatformView {
    private var container: UIView!
    private let channel: FlutterMethodChannel!

    private lazy var exampleBanner: String = "/6499/example/banner"

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

    //        let customTargeting = argument["customTargeting"] as? [String: Any]
    //        let testDevices = argument["testDevices"] as? [String]

    private func load(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments as! Dictionary<String, Any>
        let isDevelop = argument["isDevelop"] as? Bool ?? false
        let adSizesArgument = argument["adSizes"] as! [String]
        let widthsArgument = argument["widths"] as! [Double]
        let heightsArgument = argument["heights"] as! [Double]
        let isPortrait = argument["isPortrait"] as? Bool ?? true

        let adSize = convertToAdSizes(adSizesArgument, widths: widthsArgument, heights: heightsArgument, isPortrait: isPortrait, result: result).first!
        let adUnitId = argument["adUnitId"] as? String

        if loadBanner(adSize: adSize, adUnitId: isDevelop ? exampleBanner : adUnitId) {
            result(nil)
        } else {
            result(FlutterError.controllerError)
        }

        result(nil)
    }


    func loadBanner(adSize: GADAdSize, adUnitId: String?) -> Bool {

        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            return false
        }
        let bannerView = GAMBannerView(adSize: adSize)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = rootViewController
        bannerView.load(GAMRequest())
        return true
    }

    private func addBannerViewToView(_ bannerView: GAMBannerView) {
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

    private func convertToAdSizes(_ names: [String], widths: [Double], heights: [Double], isPortrait: Bool, result: @escaping FlutterResult) -> [GADAdSize] {
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
                if isPortrait {
                    return kGADAdSizeSmartBannerPortrait
                } else {
                    return kGADAdSizeSmartBannerLandscape
                }
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
    func adViewDidReceiveAd(_: GADBannerView) {
        channel.invokeMethod("onAdLoaded", arguments: nil)
    }

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.localizedDescription])
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_: GADBannerView) {
        channel.invokeMethod("onAdOpened", arguments: nil)
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
