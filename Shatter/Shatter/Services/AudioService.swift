import AVFoundation

class AudioService {
    static let shared = AudioService()
    private var bgmPlayer: AVAudioPlayer?

    private init() {}

    func playBGM() {}
    func stopBGM() { bgmPlayer?.stop() }

    func playSE(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
