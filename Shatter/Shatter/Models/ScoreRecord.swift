import Foundation

struct LevelProgress: Codable {
    var levelId: Int
    var isUnlocked: Bool
    var bestScore: Int = 0
    var bestStars: Int = 0

    mutating func update(score: Int, stars: Int) {
        if score > bestScore { bestScore = score }
        if stars > bestStars { bestStars = stars }
    }
}
