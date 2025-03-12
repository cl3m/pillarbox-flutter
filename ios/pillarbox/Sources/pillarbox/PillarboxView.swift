import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

struct PillarboxView: View {
    let uri: String
    let player: Player

    init(uri: String) {
        self.uri = uri
        if uri.starts(with: "urn:rts") {
            self.player = Player(item: .urn(uri))
        } else {
            self.player = Player(item: .simple(url: URL(string: uri)!))
        }
    }

    var body: some View {
        SystemVideoView(player: player)
            .ignoresSafeArea()
    }
}
