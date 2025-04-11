import Combine
import Flutter
import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

class PillarboxController {
    let uri: String
    var player: Player?
    let channel: FlutterMethodChannel
    var cancellables = Set<AnyCancellable>()

    init(identifier: Int, uri: String, messenger: FlutterBinaryMessenger) {
        self.uri = uri
        if uri.starts(with: "urn:rts") {
            self.player = Player(item: .urn(uri))
        } else {
            self.player = Player(item: .simple(url: URL(string: uri)!))
        }
        self.channel = FlutterMethodChannel(name: "pillarbox/\(identifier)", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) in
            switch call.method {
            case "play":
                if self?.player?.playbackState == .idle {
                    self?.player?.seek(to: .zero)
                }
                self?.player?.actionAtItemEnd = .pause
                self?.player?.play()
                result(nil)
            case "pause":
                self?.player?.pause()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        player?.propertiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] properties in
                self?.channel.invokeMethod("properties", arguments: [
                    "state": "\(properties.playbackState)",
                    "rate": "\(properties.rate)",
                    "duration": "\(properties.seekableTimeRange.duration.seconds)", // TODO: no public duration property
                    "position": "\(properties.time().seconds)",
                    "presentationSizeHeight": "\(properties.presentationSize?.height ?? 0)",
                    "presentationSizeWidth": "\(properties.presentationSize?.width ?? 0)",
                ])
            }.store(in: &cancellables)

        Timer.TimerPublisher(interval: 0.5, runLoop: .main, mode: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.player?.playbackState == .playing {
                    self?.channel.invokeMethod("position", arguments: [
                        "position": "\(self?.player?.time().seconds ?? 0.0)",
                    ])
                }
            }
            .store(in: &cancellables)
    }
}
