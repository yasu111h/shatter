import Foundation

class ScoreService: ObservableObject {
    static let shared = ScoreService()
    private let progressKey = "shatter_level_progress"

    @Published private(set) var progresses: [LevelProgress] = []

    private init() {
        loadProgresses()
    }

    // 全ステージのプログレスを取得
    func progress(for levelId: Int) -> LevelProgress {
        return progresses.first(where: { $0.levelId == levelId }) ?? LevelProgress(levelId: levelId, isUnlocked: levelId == 1)
    }

    // クリア時に保存
    func recordClear(levelId: Int, score: Int, stars: Int) {
        var idx = progresses.firstIndex(where: { $0.levelId == levelId })
        if idx == nil {
            progresses.append(LevelProgress(levelId: levelId, isUnlocked: true))
            idx = progresses.count - 1
        }
        guard let safeIdx = idx else { return }
        progresses[safeIdx].update(score: score, stars: stars)

        // 次のステージをアンロック
        let nextId = levelId + 1
        if nextId <= 20 {
            if let nextIdx = progresses.firstIndex(where: { $0.levelId == nextId }) {
                progresses[nextIdx].isUnlocked = true
            } else {
                progresses.append(LevelProgress(levelId: nextId, isUnlocked: true))
            }
        }
        saveProgresses()
    }

    private func loadProgresses() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let saved = try? JSONDecoder().decode([LevelProgress].self, from: data) {
            progresses = saved
        } else {
            // 初期状態: ステージ1だけアンロック
            progresses = (1...20).map { LevelProgress(levelId: $0, isUnlocked: $0 == 1) }
        }
    }

    private func saveProgresses() {
        if let data = try? JSONEncoder().encode(progresses) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    // デバッグ用：全ステージアンロック
    func unlockAll() {
        for i in 0..<progresses.count {
            progresses[i].isUnlocked = true
        }
        saveProgresses()
    }
}
