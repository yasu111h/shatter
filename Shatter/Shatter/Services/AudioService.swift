import Foundation
import AVFoundation

class AudioService: ObservableObject {
    static let shared = AudioService()

    @Published var bgmEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(bgmEnabled, forKey: "shatter_bgm")
            bgmEnabled ? playBGM() : stopBGM()
        }
    }

    @Published var seEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(seEnabled, forKey: "shatter_se")
        }
    }

    private var bgmPlayer: AVAudioPlayer?
    private var sePlayers: [String: AVAudioPlayer] = [:]

    private init() {
        bgmEnabled = UserDefaults.standard.object(forKey: "shatter_bgm") as? Bool ?? true
        seEnabled = UserDefaults.standard.object(forKey: "shatter_se") as? Bool ?? true
    }

    // MARK: - BGM
    func playBGM() {
        guard bgmEnabled else { return }
        // BGMファイルがない場合はスキップ
        guard let url = Bundle.main.url(forResource: "bgm_game", withExtension: "mp3") else { return }
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.4
            bgmPlayer?.play()
        } catch {
            print("BGM再生エラー: \(error)")
        }
    }

    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    func pauseBGM() {
        bgmPlayer?.pause()
    }

    func resumeBGM() {
        guard bgmEnabled else { return }
        bgmPlayer?.play()
    }

    // MARK: - SE
    func playSE(_ name: String) {
        guard seEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7
            player.play()
            sePlayers[name] = player
        } catch {
            print("SE再生エラー: \(error)")
        }
    }

    // SEキー名定数
    enum SE {
        static let hit = "se_hit"
        static let blockBreak = "se_break"
        static let paddleHit = "se_paddle"
        static let clear = "se_clear"
        static let gameOver = "se_gameover"
        static let ballLost = "se_balllost"
    }
}
