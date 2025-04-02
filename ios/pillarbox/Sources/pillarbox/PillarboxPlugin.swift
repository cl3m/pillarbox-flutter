import Flutter
import UIKit

public class PillarboxPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // TODO: Find flutter view controller correcly for add to app case
        let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as! FlutterViewController
        let factory = PillarboxNativeViewFactory(messenger: registrar.messenger(), flutterViewController: flutterViewController)
        registrar.register(factory, withId: "pillarbox-view")

        let channel = FlutterMethodChannel(name: "pillarbox", binaryMessenger: registrar.messenger())
        let instance = PillarboxPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        pluginregistrar = registrar
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            var arguments = call.arguments as! [String: Any]
            var dataSource = arguments["dataSource"] as! String
            var identifier = arguments["identifier"] as! Int
            controllers[identifier] = PillarboxController(identifier: identifier, uri: dataSource, messenger: pluginregistrar!.messenger())
            result("\(controllers.count) pillarbox controllers")
        case "dispose":
            var arguments = call.arguments as! [String: Any]
            var identifier = arguments["identifier"] as! Int
            controllers[identifier]?.player?.pause()
            controllers[identifier]?.player = nil
            controllers[identifier] = nil
            result("\(controllers.count) pillarbox controllers")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

var controllers: [Int: PillarboxController] = [:]
private var pluginregistrar: FlutterPluginRegistrar!
