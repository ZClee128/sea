import SwiftUI
import AVKit

struct VideoPlayerLayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(player: player)
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        self.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
