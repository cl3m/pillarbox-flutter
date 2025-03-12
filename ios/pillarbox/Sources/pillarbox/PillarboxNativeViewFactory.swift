import Flutter
import SwiftUI
import UIKit

class PillarboxNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private let flutterViewController: FlutterViewController

    init(messenger: FlutterBinaryMessenger, flutterViewController: FlutterViewController) {
        self.messenger = messenger
        self.flutterViewController = flutterViewController
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PillarboxNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            flutterViewController: flutterViewController
        )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}
