import Foundation
import SpriteKit

// ブロックの耐久値タイプ
enum BlockType: Int, Codable {
    case weak = 1
    case medium = 2
    case strong = 3

    var color: SKColor {
        switch self {
        case .weak:   return SKColor(hex: "#00E5FF") // シアン
        case .medium: return SKColor(hex: "#FF9500") // オレンジ
        case .strong: return SKColor(hex: "#FF3B30") // 赤
        }
    }

    var points: Int {
        switch self {
        case .weak:   return 10
        case .medium: return 20
        case .strong: return 30
        }
    }
}

// レベルJSON用のブロックデータ
struct BlockData: Codable {
    let row: Int
    let col: Int
    let type: Int // 1〜3
}

// ゲーム中のブロック状態
struct Block {
    let row: Int
    let col: Int
    var hp: Int
    var type: BlockType
    var node: SKSpriteNode?

    init(data: BlockData) {
        self.row = data.row
        self.col = data.col
        self.hp = data.type
        self.type = BlockType(rawValue: data.type) ?? .weak
    }

    init(row: Int, col: Int, hp: Int) {
        self.row = row
        self.col = col
        self.hp = hp
        self.type = BlockType(rawValue: hp) ?? .weak
    }

    var isAlive: Bool { hp > 0 }

    var currentColor: SKColor {
        switch hp {
        case 3: return BlockType.strong.color
        case 2: return BlockType.medium.color
        default: return BlockType.weak.color
        }
    }
}

// SKColor hex拡張
extension SKColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
