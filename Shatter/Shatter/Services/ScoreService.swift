import Foundation

class ScoreService {
    static let shared = ScoreService()
    private let key = "shatter_progress"
    private(set) var progresses: [LevelProgress] = []

    private init() {
        load()
        if progresses.isEmpty {
            progresses = [LevelProgress(levelId: 1, isUnlocked: true)]
        }
    }

    func isUnlocked(_ levelId: Int) -> Bool {
        progresses.first(where: { $0.levelId == levelId })?.isUnlocked ?? (levelId == 1)
    }

    func bestStars(for levelId: Int) -> Int {
        progresses.first(where: { $0.levelId == levelId })?.bestStars ?? 0
    }

    func recordClear(levelId: Int, score: Int, stars: Int) {
        if let idx = progresses.firstIndex(where: { $0.levelId == levelId }) {
            progresses[idx].update(score: score, stars: stars)
        } else {
            var p = LevelProgress(levelId: levelId, isUnlocked: true)
            p.update(score: score, stars: stars)
            progresses.append(p)
        }
        let nextId = levelId + 1
        if nextId <= 20 {
            if progresses.firstIndex(where: { $0.levelId == nextId }) == nil {
                progresses.append(LevelProgress(levelId: nextId, isUnlocked: true))
            } else if let idx = progresses.firstIndex(where: { $0.levelId == nextId }) {
                progresses[idx].isUnlocked = true
            }
        }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progresses) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([LevelProgress].self, from: data) else { return }
        progresses = decoded
    }
}
