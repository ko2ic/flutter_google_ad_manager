package com.ko2ic.fluttergoogleadmanager

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory class of Banner for Android.
 */
class BannerViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {


    override fun create(context: Context, id: Int, parameter: Any?): PlatformView {
        return BannerView(context, id, messenger)
    }

}