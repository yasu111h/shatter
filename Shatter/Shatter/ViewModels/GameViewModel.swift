import Foundation
import Combine
import SpriteKit

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = GameState()
    @Published var scene: GameScene?

    private let scoreService = ScoreService.shared
    private let levelLoader = LevelLoader.shared
    private var cancellables = Set<AnyCancellable>()

    // ゲームシーンを初期化
    func setupScene(levelId: Int, size: CGSize) {
        let levelData = levelLoader.load(levelId: levelId)
        let newScene = GameScene(size: size)
        newScene.scaleMode = .aspectFill
        newScene.gameViewModel = self
        newScene.loadLevel(levelData)
        gameState.reset(level: levelId)
        scene = newScene
    }

    // GameSceneからのコールバック
    func onScoreAdded(_ points: Int) {
        gameState.addScore(points)
    }

    func onLifeLost() {
        gameState.loseLife()
        if gameState.phase != .gameOver {
            gameState.phase = .playing
        }
    }

    func onBlockDestroyed() {
        gameState.destroyedBlocks += 1
        if gameState.isCleared {
            gameState.phase = .clear
            scoreService.recordClear(
                levelId: gameState.currentLevel,
                score: gameState.score,
                stars: gameState.stars
            )
            AudioService.shared.playSE(AudioService.SE.clear)
        }
    }

    func onTotalBlocksSet(_ count: Int) {
        gameState.totalBlocks = count
    }

    // ポーズ
    func togglePause() {
        if gameState.phase == .playing {
            gameState.phase = .paused
            scene?.isPaused = true
            AudioService.shared.pauseBGM()
        } else if gameState.phase == .paused {
            gameState.phase = .playing
            scene?.isPaused = false
            AudioService.shared.resumeBGM()
        }
    }

    // ゲーム開始（ボール発射）
    func startGame() {
        guard gameState.phase == .idle else { return }
        gameState.phase = .playing
        scene?.launchBall()
        AudioService.shared.playBGM()
    }

    // リスタート
    func restart() {
        setupScene(levelId: gameState.currentLevel, size: scene?.size ?? CGSize(width: 390, height: 844))
        gameState.reset(level: gameState.currentLevel)
    }

    // 次のステージへ
    func nextLevel() {
        let nextId = min(gameState.currentLevel + 1, 20)
        setupScene(levelId: nextId, size: scene?.size ?? CGSize(width: 390, height: 844))
    }
}
