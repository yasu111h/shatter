import Foundation

class LevelLoader {
    static let shared = LevelLoader()
    private init() {}

    func load(levelId: Int) -> LevelData {
        // まずBundleからJSONを試みる
        if let url = Bundle.main.url(forResource: "level_\(String(format: "%03d", levelId))", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let level = try? JSONDecoder().decode(LevelData.self, from: data) {
            return level
        }
        // JSONがなければデフォルトパターンを使用
        return LevelData.defaultLevel(id: levelId)
    }

    func allLevels() -> [LevelData] {
        return (1...20).map { load(levelId: $0) }
    }
}
