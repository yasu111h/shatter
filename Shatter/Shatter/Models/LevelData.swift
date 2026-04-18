import Foundation

struct LevelData: Codable {
    let levelNumber: Int
    let gridRows: Int
    let gridColumns: Int
    let blockLayout: [[Int]]  // 0=なし, 1=HP1, 2=HP2, 3=HP3
    let ballSpeedMultiplier: Double
    let paddleWidthMultiplier: Double
}
