package com.ko2ic.fluttergoogleadmanager

import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.doubleclick.PublisherInterstitialAd
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class InterstitialAd(registrar: PluginRegistry.Registrar, private val channel: MethodChannel) :
    MethodChannel.MethodCallHandler {

    private val interstitialAd = PublisherInterstitialAd(registrar.context())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> load(call, result)
            "show" -> show(result)
            "dispose" -> dispose(result)
            else -> result.notImplemented()
        }
    }

    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val isDevelop = call.argument<Boolean>("isDevelop") ?: false

        if (interstitialAd.adUnitId.isNullOrEmpty()) {
            if (isDevelop) {
                interstitialAd.adUnitId = "/6499/example/interstitial"
            } else {
                interstitialAd.adUnitId = call.argument<String>("adUnitId")
            }
            interstitialAd.adListener = InterstitialAdListener(channel)
        }
        val adRequest = PublisherAdRequest.Builder().build()
        interstitialAd.loadAd(adRequest)
        result.success(null)
    }

    private fun show(result: MethodChannel.Result) {
        if (interstitialAd.isLoaded) {
            interstitialAd.show()
            result.success(null)
        } else {
            result.error("not_loaded_yet", "The interstitial wasn't loaded yet", null)
        }
    }

    private fun dispose(result: MethodChannel.Result) {
        interstitialAd.adListener = null
        result.success(null)
    }

    class InterstitialAdListener(private val channel: MethodChannel) : AdListener() {
        /**
         * It will run when the ad loading is complete.
         */
        override fun onAdLoaded() {
            super.onAdLoaded()
            channel.invokeMethod("onAdLoaded", null)
        }

        /**
         * Called on failure.
         * The [errorCode] parameter indicates the type of error that occurred.
         */
        override fun onAdFailedToLoad(errorCode: Int) {
            channel.invokeMethod("onAdFailedToLoad", mapOf("errorCode" to errorCode))
        }

        /**
         * Called when the ad is displayed.
         */
        override fun onAdOpened() {
            super.onAdOpened()
            channel.invokeMethod("onAdOpened", null)
        }

        /**
         * Called when the interstitial ad is closed.
         */
        override fun onAdClosed() {
            super.onAdClosed()
            channel.invokeMethod("onAdClosed", null)
        }

        /**
         * called when the user has left the app.
         */
        override fun onAdLeftApplication() {
            super.onAdLeftApplication()
            channel.invokeMethod("onAdLeftApplication", null)
        }
    }
}
