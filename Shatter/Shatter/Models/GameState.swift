import Foundation

// ゲームの状態
enum GamePhase {
    case idle       // 待機中（ボール発射待ち）
    case playing    // プレイ中
    case paused     // ポーズ中
    case clear      // クリア
    case gameOver   // ゲームオーバー
}

// ゲーム全体の状態を管理するモデル
struct GameState {
    var phase: GamePhase = .idle
    var score: Int = 0
    var lives: Int = 3
    var currentLevel: Int = 1
    var totalBlocks: Int = 0
    var destroyedBlocks: Int = 0

    var remainingBlocks: Int { totalBlocks - destroyedBlocks }
    var isCleared: Bool { remainingBlocks <= 0 && totalBlocks > 0 }

    // スター評価
    var stars: Int {
        switch lives {
        case 3: return 3
        case 2: return 2
        default: return 1
        }
    }

    mutating func reset(level: Int) {
        phase = .idle
        score = 0
        lives = 3
        currentLevel = level
        destroyedBlocks = 0
        totalBlocks = 0
    }

    mutating func addScore(_ points: Int) {
        score += points
    }

    mutating func loseLife() {
        lives = max(0, lives - 1)
        if lives == 0 {
            phase = .gameOver
        }
    }
}
