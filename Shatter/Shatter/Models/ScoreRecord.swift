import Foundation

struct ScoreRecord: Codable, Identifiable {
    let id: UUID
    let levelId: Int
    let score: Int
    let stars: Int
    let date: Date

    init(levelId: Int, score: Int, stars: Int) {
        self.id = UUID()
        self.levelId = levelId
        self.score = score
        self.stars = stars
        self.date = Date()
    }
}

// ステージのクリア状況
struct LevelProgress: Codable {
    let levelId: Int
    var isUnlocked: Bool
    var isCleared: Bool
    var bestScore: Int
    var bestStars: Int

    init(levelId: Int, isUnlocked: Bool = false) {
        self.levelId = levelId
        self.isUnlocked = isUnlocked
        self.isCleared = false
        self.bestScore = 0
        self.bestStars = 0
    }

    mutating func update(score: Int, stars: Int) {
        isCleared = true
        if score > bestScore { bestScore = score }
        if stars > bestStars { bestStars = stars }
    }
}
