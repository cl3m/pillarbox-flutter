package com.example.pillarbox

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PillarboxNativeViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(
        context: Context, id: Int, args: Any?
    ): PlatformView {
        return PillarboxNativeView(
            context, messenger, id, args
        )
    }
}