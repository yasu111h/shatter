import SwiftUI

enum BlockType: String, Codable {
    case normal
    case hard
    case bonus
}

struct Block: Identifiable {
    let id: UUID
    var hp: Int
    let type: BlockType
    var isAlive: Bool { hp > 0 }

    init(hp: Int = 1, type: BlockType = .normal) {
        self.id = UUID()
        self.hp = hp
        self.type = type
    }

    mutating func hit() {
        hp = max(0, hp - 1)
    }

    var color: Color {
        switch hp {
        case 3: return Color(hex: "#FF3B3B")
        case 2: return Color(hex: "#FF9500")
        default: return Color(hex: "#00E5FF")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
