import Flutter
import UIKit

public class PillarboxPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        //TODO: Find flutter view controller correcly for add to app case
        let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as! FlutterViewController
        let factory = PillarboxNativeViewFactory(messenger: registrar.messenger(), flutterViewController: flutterViewController)
        registrar.register(factory, withId: "pillarbox-view")
    }
}
