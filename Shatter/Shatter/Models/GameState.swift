import Foundation

enum GamePhase: Equatable {
    case idle
    case playing
    case paused
    case clear
    case gameOver
}

struct GameState {
    var phase: GamePhase = .idle
    var score: Int = 0
    var lives: Int = 3
    var stars: Int = 0
    var currentLevel: Int = 1
    var blocks: [[Block?]] = []
    var elapsedTime: Double = 0
}
