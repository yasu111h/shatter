import SpriteKit
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    private(set) var scene: GameScene?

    func setupScene(levelId: Int, size: CGSize) {
        gameState = GameState()
        gameState.currentLevel = levelId
        let s = GameScene(size: size)
        s.scaleMode = .resizeFill
        s.gameViewModel = self
        scene = s
        s.setupLevel(levelId: levelId)
    }

    func togglePause() {
        if gameState.phase == .playing {
            gameState.phase = .paused
            scene?.isPaused = true
        } else if gameState.phase == .paused {
            gameState.phase = .playing
            scene?.isPaused = false
        }
    }

    func restart() {
        guard let s = scene else { return }
        gameState.phase = .idle
        gameState.score = 0
        gameState.lives = 3
        gameState.stars = 0
        s.isPaused = false
        s.setupLevel(levelId: gameState.currentLevel)
    }

    func nextLevel() {
        let next = gameState.currentLevel + 1
        setupScene(levelId: next, size: scene?.size ?? CGSize(width: 390, height: 750))
    }

    // GameSceneから呼ばれる
    func addScore(_ points: Int) {
        gameState.score += points
    }

    func loseLife() {
        gameState.lives -= 1
        if gameState.lives <= 0 {
            gameState.phase = .gameOver
        }
    }

    func stageClear() {
        let stars: Int
        switch gameState.lives {
        case 3: stars = 3
        case 2: stars = 2
        default: stars = 1
        }
        gameState.stars = stars
        gameState.phase = .clear
        ScoreService.shared.recordClear(levelId: gameState.currentLevel,
                                        score: gameState.score, stars: stars)
    }
}
