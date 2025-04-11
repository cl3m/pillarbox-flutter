package com.example.pillarbox

import android.content.Context
import android.graphics.Color
import android.media.session.PlaybackState
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.ui.PlayerView
import ch.srgssr.pillarbox.core.business.PillarboxExoPlayer
import ch.srgssr.pillarbox.core.business.SRGMediaItem
import ch.srgssr.pillarbox.player.PillarboxExoPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PillarboxController internal constructor(private val context: Context?, identifier: Int, uri: String, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    lateinit var player: PillarboxExoPlayer
    private val handler = Handler(Looper.getMainLooper())
    private val position = object : Runnable {
        override fun run() {
            if (player.isPlaying) {
                channel.invokeMethod("current_position", player.currentPosition)
            }
            handler.postDelayed(this, 500)
        }
    }

    init {
        channel = MethodChannel(messenger, "pillarbox/$identifier")
        channel.setMethodCallHandler(this)

        player = PillarboxExoPlayer(context!!)
        // Make the player ready to play content
        player.prepare()
        val mediaItem = if (uri.startsWith("urn:rts")) {
            SRGMediaItem(uri);
        } else {
            MediaItem.fromUri(uri)
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
                channel.invokeMethod("state", state)
                channel.invokeMethod("duration", player.duration)
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                super.onVideoSizeChanged(videoSize)
                channel.invokeMethod("video_size", mapOf("height" to videoSize.height, "width" to videoSize.width))
            }

            override fun onPositionDiscontinuity(oldPosition: Player.PositionInfo, newPosition: Player.PositionInfo, reason: Int) {
                super.onPositionDiscontinuity(oldPosition, newPosition, reason)
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                super.onIsPlayingChanged(isPlaying)
                channel.invokeMethod("is_playing", if (isPlaying) "true" else "false")
            }
        })

        handler.postDelayed(position, 500)
    }

    override fun onMethodCall(
        methodCall: MethodCall, result: MethodChannel.Result
    ) {
        when (methodCall.method) {
            "play" -> {
                if (player.playbackState == Player.STATE_ENDED) {
                    player.seekTo(0)
                }
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
}