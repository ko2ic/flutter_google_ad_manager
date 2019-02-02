package com.ko2ic.fluttergoogleadmanager

import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.reward.RewardItem
import com.google.android.gms.ads.reward.RewardedVideoAdListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class RewardedAd(private val registrar: PluginRegistry.Registrar, private val channel: MethodChannel) :
    MethodChannel.MethodCallHandler {

    private val rewardedAd = MobileAds.getRewardedVideoAdInstance(registrar.context())

    init {
        rewardedAd.rewardedVideoAdListener = RewardedAdListener(channel);
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> load(call, result)
            "show" -> show(result)
            "dispose" -> dispose(result)
            "pause" -> rewardedAd.pause(registrar.context())
            "resume" -> rewardedAd.resume(registrar.context())
            else -> result.notImplemented()
        }
    }

    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val isDevelop = call.argument<Boolean>("isDevelop") ?: false

        if (isDevelop) {
            rewardedAd.loadAd("/6499/example/rewarded-video", PublisherAdRequest.Builder().build())
        } else {
            rewardedAd.loadAd(call.argument<String>("adUnitId"), PublisherAdRequest.Builder().build())
        }
        result.success(null)
    }

    private fun show(result: MethodChannel.Result) {
        if (rewardedAd.isLoaded) {
            rewardedAd.show()
            result.success(null)
        } else {
            result.error("not_loaded_yet", "The Rewarded Ads wasn't loaded yet", null)
        }
    }

    private fun dispose(result: MethodChannel.Result) {
        rewardedAd.destroy(registrar.context())
        result.success(null)
    }

    class RewardedAdListener(private val channel: MethodChannel) : RewardedVideoAdListener {
        override fun onRewarded(reward: RewardItem) {
            channel.invokeMethod("onRewarded", mapOf("type" to reward.type, "amount" to reward.amount))
        }

        override fun onRewardedVideoAdLeftApplication() {
            channel.invokeMethod("onAdLeftApplication", null)
        }

        override fun onRewardedVideoAdClosed() {
            channel.invokeMethod("onAdClosed", null)
        }

        override fun onRewardedVideoAdFailedToLoad(errorCode: Int) {
            channel.invokeMethod("onAdFailedToLoad", mapOf("errorCode" to errorCode))
        }

        override fun onRewardedVideoAdLoaded() {
            channel.invokeMethod("onAdLoaded", null)
        }

        override fun onRewardedVideoAdOpened() {
            channel.invokeMethod("onAdOpened", null)
        }

        override fun onRewardedVideoStarted() {
            channel.invokeMethod("onVideoStarted", null)
        }

        override fun onRewardedVideoCompleted() {
            channel.invokeMethod("onVideoCompleted", null)
        }
    }
}
