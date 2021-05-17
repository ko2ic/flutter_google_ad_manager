//
//  NativeAd.swift
//  flutter_google_ad_manager
//
//  Created by Alvaro De la Cruz on 20/11/20.
//

import Foundation
import GoogleMobileAds

class NativeAd: SwiftFlutterGoogleAdManagerPlugin {
    
    private var templateId: String!
    private var adLoader: GADAdLoader!
    
    private var ad: GADNativeCustomTemplateAd?
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
        case "getParameter":
            getParameter(call, result: result)
        case "performClick":
            performClick(call, result: result)
        case "dispose":
            dispose(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func load(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments as! Dictionary<String, Any>
        let isDevelop = argument["isDevelop"] as? Bool ?? false
        let viewController = UIApplication.shared.delegate!.window!!.rootViewController!
        
        if isDevelop {
            let adUnit = "/6499/example/native"
            self.templateId = "10063170"
            
            adLoader = GADAdLoader(
                adUnitID: adUnit, rootViewController: viewController, adTypes: [ GADAdLoaderAdType.nativeCustomTemplate ], options: [])
        }else{
            let adUnit = argument["adUnitId"] as? String ?? ""
            self.templateId = argument["templateId"] as? String ?? ""
            
            adLoader = GADAdLoader(
                adUnitID: adUnit, rootViewController: viewController, adTypes: [ GADAdLoaderAdType.nativeCustomTemplate ], options: [])
        }
        let customTargeting = argument["customTargeting"] as? [String: Any]
        let request = DFPRequest()
        
        request.customTargeting = customTargeting
        
        adLoader.delegate = self
        adLoader.load(request)
        
        result(nil)
    }
    
    private func performClick(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let nativeAd = ad else {
            result(FlutterError(code: "program_error", message: "Please call load() method first.", details: nil))
            return
        }
        let argument = call.arguments as! Dictionary<String, Any>
        if let parameter = argument["parameter"] as? String {
            nativeAd.performClickOnAsset(withKey: parameter)
        }else{
            result(FlutterError(code: "MISSING_PARAMETER", message: "You must specify the parameter to perform this action", details: nil))
        }
        
    }
    
    private func getParameter(_ call :FlutterMethodCall, result: @escaping FlutterResult){
        guard let nativeAd = ad else {
            result(FlutterError(code: "program_error", message: "Please call load() method first.", details: nil))
            return
        }
        let argument = call.arguments as! Dictionary<String, Any>
        if let type = argument["type"] as? String, let parameter = argument["parameter"] as? String {
            switch(type){
            case "image":
                result(nativeAd.image(forKey: parameter)?.imageURL?.absoluteString)
            case "text":
                result(nativeAd.string(forKey: parameter))
            default:
                result(FlutterError(code: "INVALID_TYPE", message: "The type you specified is invalid", details: nil))
            }
        }else{
            result(FlutterError(code: "MISSING_PARAMETER", message: "You must specify the parameter you want", details: nil))
        }
    }
    
    private func dispose(_: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}

extension NativeAd: GADNativeCustomTemplateAdLoaderDelegate {
    
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return [templateId]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        channel.invokeMethod("onAdLoaded", arguments: nil)
        
        self.ad = nativeCustomTemplateAd
        self.ad?.recordImpression()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("onAdFailedToLoad", arguments: ["errorCode": error.code])
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        channel.invokeMethod("onAdOpened", arguments: nil)
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        channel.invokeMethod("onAdClosed", arguments: nil)
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        channel.invokeMethod("onAdLeftApplication", arguments: nil)
    }
}
