package com.example.pillarbox

import android.content.Context
import android.graphics.Color
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.ui.PlayerView
import ch.srgssr.pillarbox.core.business.PillarboxExoPlayer
import ch.srgssr.pillarbox.core.business.SRGMediaItem
import ch.srgssr.pillarbox.player.PillarboxExoPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class class PillarboxNativeView internal constructor(private val context: Context?, messenger: BinaryMessenger?, id: Int, args: Any?) : PlatformView {
    private val rootView: PlayerView
    
    init {
        rootView = PlayerView(context!!)
        val arguments = args as Map<*, *>
        val identifier = arguments["identifier"] as Int
        var player = controllers[identifier]!!.player
        rootView.player = player     
    }

    override fun getView(): View {
        return rootView
    }
}