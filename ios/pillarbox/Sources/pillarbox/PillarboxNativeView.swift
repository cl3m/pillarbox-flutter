import Combine
import Flutter
import SwiftUI

class PillarboxNativeView: UIView, FlutterPlatformView {
    var cancellables = Set<AnyCancellable>()
    let rootView: PillarboxView
    let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        flutterViewController: FlutterViewController
    ) {
        let arguments = args as! [String: String]
        let uri = arguments["uri"]!
        rootView = PillarboxView(uri: uri)
        channel = FlutterMethodChannel(name: "Pillarbox/\(viewId)", binaryMessenger: messenger!)
        super.init(frame: .zero)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) in
            switch call.method {
            case "play":
                self?.rootView.player.play()
                result(nil)
            case "pause":
                self?.rootView.player.pause()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        UIHostingController(rootView: rootView).attach(to: flutterViewController, in: self)
        rootView.player.propertiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] properties in
                self?.channel.invokeMethod("properties", arguments: ["state": "\(properties.playbackState)"])
            }.store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    nonisolated func view() -> UIView {
        return self
    }
}

extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension UIHostingController {
    func attach(to viewController: UIViewController, in view: UIView) {
        viewController.addChild(self)
        view.addConstrained(subview: self.view)
        didMove(toParent: viewController)
    }
}
