import Foundation

class LevelLoader {
    static func load(levelId: Int) -> LevelData? {
        let name = String(format: "level_%03d", levelId)
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let level = try? JSONDecoder().decode(LevelData.self, from: data) else {
            return LevelLoader.fallback(levelId: levelId)
        }
        return level
    }

    static func fallback(levelId: Int) -> LevelData {
        let speed = 1.0 + Double(levelId - 1) * 0.05
        let rows = min(4 + levelId / 3, 8)
        var layout: [[Int]] = []
        for r in 0..<rows {
            var row: [Int] = []
            for _ in 0..<7 {
                let hp = min((r / 3) + 1, 3)
                row.append(hp)
            }
            layout.append(row)
        }
        return LevelData(levelNumber: levelId, gridRows: rows, gridColumns: 7,
                         blockLayout: layout, ballSpeedMultiplier: speed, paddleWidthMultiplier: 1.0)
    }
}
