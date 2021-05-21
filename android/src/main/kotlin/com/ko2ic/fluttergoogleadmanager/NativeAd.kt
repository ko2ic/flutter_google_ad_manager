package com.ko2ic.fluttergoogleadmanager

import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.formats.NativeCustomTemplateAd
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class NativeAd(private val registrar: PluginRegistry.Registrar, private val channel: MethodChannel) : MethodChannel.MethodCallHandler {
    private lateinit var builder: AdLoader.Builder
    private lateinit var ad: NativeCustomTemplateAd

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> load(call, result)
            "dispose" -> dispose(result)
            "performClick" -> performClick(call, result)
            "getParameter" -> getParameter(call, result)
            else -> result.notImplemented()
        }
    }

    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val isDevelop = call.argument<Boolean>("isDevelop") ?: false
        if (isDevelop) {
            builder = AdLoader.Builder(registrar.context(), "/6499/example/native")
                    .forCustomTemplateAd("10063170",
                            { ad ->
                                this.ad = ad
                                this.ad.recordImpression()
                            }, null)
        } else {
            val adUnit = call.argument<String>("adUnitId")
            val templateId = call.argument<String>("templateId")
            builder = AdLoader.Builder(registrar.context(), adUnit)
                    .forCustomTemplateAd(templateId,
                            { ad ->
                                this.ad = ad
                                this.ad.recordImpression()
                            }, null)
        }
        val adRequestBuilder = PublisherAdRequest.Builder()
        val customTargeting = call.argument("customTargeting") as? Map<String, Any>

        customTargeting?.let {
            it.entries.forEach { (key, value) ->
                when(value){
                    is String -> adRequestBuilder.addCustomTargeting(key, value)
                    is List<*> -> adRequestBuilder.addCustomTargeting(key, value.filterIsInstance<String>())
                    else -> throw IllegalArgumentException("customTargeting: values must be either Strings or Lists of Strings, but got $value")
                }
            }
        }
        val adLoader = builder.withAdListener(NativeAdListener(channel))
                .build()
        adLoader.loadAd(adRequestBuilder.build())

        result.success(null)
    }

    private fun dispose(result: MethodChannel.Result) {
        ad.destroy()
        result.success(null)
    }

    private fun performClick(call: MethodCall, result: MethodChannel.Result) {
        val parameter = call.argument<String>("parameter")
        if (parameter != null) {
            ad.performClick(parameter)
            result.success(null)
        } else {
            result.error("MISSING_PARAMETER", "You must specify the parameter to perform this action", null)
        }
    }

    private fun getParameter(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<String>("type")
        val parameter = call.argument<String>("parameter")

        if (type != null) {
            if (parameter != null) {
                when (type) {
                    "image" -> result.success(ad.getImage(parameter).uri.toString())
                    "text" -> result.success(ad.getText(parameter).toString())
                    else -> result.error("INVALID_TYPE", "The type you specified is invalid", null)
                }
            } else {
                result.error("MISSING_PARAMETER", "You must specify the parameter you want", null)
            }
        } else {
            result.error("MISSING_TYPE", "You must send the type of parameter", null)
        }
    }

    class NativeAdListener(private val channel: MethodChannel) : AdListener() {
        override fun onAdLoaded() {
            super.onAdLoaded()
            channel.invokeMethod("onAdLoaded", null)
        }

        override fun onAdFailedToLoad(errorCode: Int) {
            channel.invokeMethod("onAdFailedToLoad", mapOf("errorCode" to errorCode))
        }

        override fun onAdOpened() {
            super.onAdOpened()
            channel.invokeMethod("onAdOpened", null)
        }

        override fun onAdClosed() {
            super.onAdClosed()
            channel.invokeMethod("onAdClosed", null)
        }

        override fun onAdLeftApplication() {
            super.onAdLeftApplication()
            channel.invokeMethod("onAdLeftApplication", null)
        }
    }
}