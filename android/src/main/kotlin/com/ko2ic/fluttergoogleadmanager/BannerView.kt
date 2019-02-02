package com.ko2ic.fluttergoogleadmanager

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.doubleclick.PublisherAdRequest
import com.google.android.gms.ads.doubleclick.PublisherAdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Banner of Google Ad Manger.
 */
class BannerView(private val context: Context, id: Int, messenger: BinaryMessenger) : PlatformView,
    MethodChannel.MethodCallHandler {

    private var container: ViewGroup?
    private var publisherAdView: PublisherAdView? = null

    private val channel = MethodChannel(messenger, "plugins.ko2ic.com/google_ad_manager/banner/$id")

    init {
        channel.setMethodCallHandler(this)

        container = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            descendantFocusability = ViewGroup.FOCUS_BLOCK_DESCENDANTS
        }
    }


    override fun getView() = container

    override fun dispose() {
        publisherAdView?.pause()
        publisherAdView?.adListener = null
        publisherAdView?.destroy()
        val parent = publisherAdView?.parent
        if (parent is ViewGroup) {
            parent.removeView(publisherAdView)
        }
        container?.removeAllViews()
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "load" -> load(methodCall, result)
            else -> result.notImplemented()
        }
    }

    private fun load(call: MethodCall, result: MethodChannel.Result) {
        val arguments: Map<String, Any> = call.arguments()

        val isDevelop = arguments.get("isDevelop") as? Boolean ?: false
        val adUnitId = arguments.get("adUnitId") as String
        val adSizesParameter =
            arguments.get("adSizes") as? List<*> ?: throw IllegalArgumentException("adSizes is required.")
        val widthsParameter =
            arguments.get("widths") as? List<*> ?: throw IllegalArgumentException("widths is required.")
        val heightsParameter =
            arguments.get("heights") as? List<*> ?: throw IllegalArgumentException("heights is required.")
        val adSizes = convertToAdSizes(
            adSizesParameter.filterIsInstance<String>(),
            widthsParameter.filterIsInstance<Int>(),
            heightsParameter.filterIsInstance<Int>()
        )

        container?.removeAllViews()
        publisherAdView?.destroy()

        val builder = PublisherAdRequest.Builder()
        this.publisherAdView = PublisherAdView(context)

        if (isDevelop) {
            publisherAdView?.adUnitId = "/6499/example/banner"
            builder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR)
            val testDevices = arguments["testDevices"] as? List<*>
            if (testDevices != null) {
                testDevices.filterIsInstance<String>().forEach { testDevice ->
                    builder.addTestDevice(testDevice)
                }
            }
        } else {
            publisherAdView?.adUnitId = adUnitId
        }

        publisherAdView?.setAdSizes(*adSizes)
        publisherAdView?.visibility = View.VISIBLE
        publisherAdView?.adListener = BannerListener(channel, publisherAdView)
        container?.addView(publisherAdView)
        val publisherAdRequest = builder.build()
        publisherAdView?.loadAd(publisherAdRequest)

        result.success(null)
    }

    private fun convertToAdSizes(adSizes: List<String>, widths: List<Int>, heights: List<Int>): Array<AdSize> {
        return adSizes.mapIndexedNotNull { index, value ->
            when (value) {
                "BANNER" -> AdSize.BANNER
                "FULL_BANNER" -> AdSize.FULL_BANNER
                "LARGE_BANNER" -> AdSize.LARGE_BANNER
                "LEADERBOARD" -> AdSize.LEADERBOARD
                "MEDIUM_RECTANGLE" -> AdSize.MEDIUM_RECTANGLE
                "SMART_BANNER" -> AdSize.SMART_BANNER
                "CUSTOM" -> AdSize(widths[index], heights[index])
                else -> {
                    throw java.lang.IllegalArgumentException("$value is unsupported.");
                }
            }
        }.toTypedArray()
    }

    /**
     * Ads Event listener.
     */
    class BannerListener(private val channel: MethodChannel, private val publisherAdView: PublisherAdView?) :
        AdListener() {
        /**
         * It will run when the ad loading is complete.
         */
        override fun onAdLoaded() {
            super.onAdLoaded()
            val params = publisherAdView?.layoutParams
            params?.width = ViewGroup.LayoutParams.MATCH_PARENT
            params?.height = ViewGroup.LayoutParams.WRAP_CONTENT
            publisherAdView?.layoutParams = params
            channel.invokeMethod("onAdLoaded", null)
        }

        /**
         * Called on failure.
         * The [errorCode] parameter indicates the type of error that occurred.
         */
        override fun onAdFailedToLoad(errorCode: Int) {
            publisherAdView?.pause()
            publisherAdView?.adListener = null
            publisherAdView?.destroy()
            val parent = publisherAdView?.parent
            if (parent is ViewGroup) {
                parent.removeView(publisherAdView)
            }
            channel.invokeMethod("onAdFailedToLoad", mapOf("errorCode" to errorCode))
        }

        /**
         * Called when a user taps an ad.
         */
        override fun onAdOpened() {
            super.onAdOpened()
            publisherAdView?.pause()
            channel.invokeMethod("onAdOpened", null)
        }

        /**
         * Called when the user returns to the application after accessing the ad's destination URL.
         */
        override fun onAdClosed() {
            super.onAdClosed()
            publisherAdView?.resume()
            channel.invokeMethod("onAdClosed", null)
        }

        /**
         * Called when the current app is moved to the background as the user launched another app (such as Google Play).
         * This method will be called after {@link BannerView.BannerListener#onAdOpened()}.
         */
        override fun onAdLeftApplication() {
            super.onAdLeftApplication()
            channel.invokeMethod("onAdLeftApplication", null)
        }
    }
}