package com.example.pillarbox

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PillarboxPlugin */
class PillarboxPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val factory = PillarboxNativeViewFactory(flutterPluginBinding.binaryMessenger)
        flutterPluginBinding.platformViewRegistry.registerViewFactory("pillarbox-view", factory)

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pillarbox")
        channel.setMethodCallHandler(this)

        binding = flutterPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "initialize") {
            val arguments = call.arguments as Map<*, *>
            val identifier = arguments["identifier"] as Int
            val uri = arguments["dataSource"] as String
            controllers[identifier] = PillarboxController(binding.applicationContext, identifier, uri, binding.binaryMessenger)
            result.success("${controllers.count()} pillarbox controllers")
        } else if (call.method == "dispose") {
            val arguments = call.arguments as Map<*, *>
            val identifier = arguments["identifier"] as Int
            controllers[identifier]?.player?.pause()
            controllers.remove(identifier)
            result.success("${controllers.count()} pillarbox controllers")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

var controllers: MutableMap<Int, PillarboxController> = mutableMapOf()
lateinit var binding: FlutterPluginBinding