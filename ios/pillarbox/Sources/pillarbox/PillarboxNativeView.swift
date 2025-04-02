import Combine
import Flutter
import SwiftUI

class PillarboxNativeView: UIView, FlutterPlatformView {
    let rootView: PillarboxView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        flutterViewController: FlutterViewController
    ) {
        let arguments = args as! [String: Any]
        let identifier = arguments["identifier"] as! Int
        rootView = PillarboxView(player: controllers[identifier]!.player!)
        super.init(frame: .zero)
        UIHostingController(rootView: rootView).attach(to: flutterViewController, in: self)
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
