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

class PillarboxNativeView internal constructor(private val context: Context?, messenger: BinaryMessenger?, id: Int, args: Any?) : PlatformView, MethodChannel.MethodCallHandler {
    private val rootView: PlayerView
    private val methodChannel: MethodChannel
    private val player: PillarboxExoPlayer

    init {
        methodChannel = MethodChannel(messenger!!, "Pillarbox/$id")
        methodChannel.setMethodCallHandler(this)

        player = PillarboxExoPlayer(context!!)
        // Make the player ready to play content
        player.prepare()
        val arguments = args as Map<String, String>
        val mediaUri = arguments["uri"]
        val mediaItem = if (mediaUri!!.startsWith("urn:rts")) {
            SRGMediaItem(mediaUri);
        } else {
            MediaItem.fromUri(mediaUri)
        }

        player.setMediaItem(mediaItem)
        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(@Player.State playbackState: Int) {
                super.onPlaybackStateChanged(playbackState)
                val state = when (playbackState) {
                    Player.STATE_IDLE -> "idle"
                    Player.STATE_BUFFERING -> "buffering"
                    Player.STATE_READY -> "ready"
                    Player.STATE_ENDED -> "ended"
                    else -> "unknown"
                }
                methodChannel.invokeMethod("state", state)
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                super.onIsPlayingChanged(isPlaying)
                methodChannel.invokeMethod("is_playing", if (isPlaying) "true" else "false")
            }
        })

        rootView = PlayerView(context)
        rootView.player = player        
    }

    override fun onMethodCall(
        methodCall: MethodCall, result: MethodChannel.Result
    ) {
        when (methodCall.method) {
            "play" -> {
                player.play()
                result.success(null)
            }

            "pause" -> {
                player.pause()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    override fun getView(): View {
        return rootView
    }

    override fun dispose() {
        //TODO("Not yet implemented")
    }
}