package com.ko2ic.fluttergoogleadmanager

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterGoogleAdManagerPlugin {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    "plugins.ko2ic.com/google_ad_manager/banner", BannerViewFactory(registrar.messenger())
                )

            val interstitialChannel =
                MethodChannel(registrar.messenger(), "plugins.ko2ic.com/google_ad_manager/interstitial")
            interstitialChannel.setMethodCallHandler(InterstitialAd(registrar, interstitialChannel))

            val rewardedChannel =
                MethodChannel(registrar.messenger(), "plugins.ko2ic.com/google_ad_manager/rewarded")
            rewardedChannel.setMethodCallHandler(RewardedAd(registrar, rewardedChannel))
        }
    }
}
