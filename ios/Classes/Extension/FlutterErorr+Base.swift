//
//  FlutterErrorEnum.swift
//  flutter_google_ad_manager
//
//  Created by 111542 on 3/20/21.
//


extension FlutterError {

    static let programError = FlutterError(code: "program_error", message: "Please call load() method first.", details: nil)

    static let controllerError = FlutterError(code: "controller_error", message: "Your controller has a problem", details: nil)

    static let errorLoadUnitId = FlutterError(code: "load_error", message: "Failed to load interstitial ad with error", details: nil)

    static let notLoad = FlutterError(code: "not_loaded_yet", message: "The Reward Ads wasn't loaded yet.", details: nil)
}
