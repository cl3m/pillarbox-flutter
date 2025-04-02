import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

struct PillarboxView: View {
    let player: Player

    var body: some View {
        SystemVideoView(player: player)
            .ignoresSafeArea()
    }
}
