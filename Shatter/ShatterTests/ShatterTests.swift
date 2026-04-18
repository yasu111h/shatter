import XCTest
@testable import Shatter

// MARK: - LevelLoader Tests
final class LevelLoaderTests: XCTestCase {

    func testDefaultLevelReturnsValidData() {
        // LevelLoader.sharedはBundleを参照するが、JSONがなければdefaultLevelを返す
        // defaultLevel のロジックを直接テスト
        let level = LevelData.defaultLevel(id: 1)
        XCTAssertEqual(level.id, 1)
        XCTAssertEqual(level.name, "STAGE 01")
        XCTAssertFalse(level.blocks.isEmpty, "ステージ1はブロックを含む必要がある")
    }

    func testDefaultLevelAllBlockTypesAreValid() {
        for stageId in 1...20 {
            let level = LevelData.defaultLevel(id: stageId)
            for block in level.blocks {
                XCTAssertTrue(block.type >= 1 && block.type <= 3,
                    "ステージ\(stageId)のブロックtype(\(block.type))は1〜3でなければならない")
            }
        }
    }

    func testDefaultLevelFor20Stages() {
        let loader = LevelLoader.shared
        let levels = loader.allLevels()
        XCTAssertEqual(levels.count, 20, "レベル数は20である必要がある")
    }

    func testDefaultLevelNameFormat() {
        let level5 = LevelData.defaultLevel(id: 5)
        XCTAssertEqual(level5.name, "STAGE 05")

        let level15 = LevelData.defaultLevel(id: 15)
        XCTAssertEqual(level15.name, "STAGE 15")
    }

    func testBlockRowColAreInBounds() {
        for stageId in 1...20 {
            let level = LevelData.defaultLevel(id: stageId)
            for block in level.blocks {
                XCTAssertTrue(block.row >= 0 && block.row < 5,
                    "rowは0〜4の範囲: \(block.row)")
                XCTAssertTrue(block.col >= 0 && block.col < 8,
                    "colは0〜7の範囲: \(block.col)")
            }
        }
    }

    func testLevelDataDecodableFromJSON() throws {
        let json = """
        {
            "id": 99,
            "name": "TEST STAGE",
            "blocks": [
                {"row": 0, "col": 0, "type": 1},
                {"row": 0, "col": 1, "type": 2},
                {"row": 1, "col": 0, "type": 3}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(LevelData.self, from: json)
        XCTAssertEqual(decoded.id, 99)
        XCTAssertEqual(decoded.name, "TEST STAGE")
        XCTAssertEqual(decoded.blocks.count, 3)
        XCTAssertEqual(decoded.blocks[0].type, 1)
        XCTAssertEqual(decoded.blocks[1].type, 2)
        XCTAssertEqual(decoded.blocks[2].type, 3)
    }
}

// MARK: - ScoreService Tests
final class ScoreServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // テスト用にUserDefaultsをリセット
        UserDefaults.standard.removeObject(forKey: "shatter_level_progress")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "shatter_level_progress")
        super.tearDown()
    }

    func testInitialStateLevel1IsUnlocked() {
        // ScoreServiceはシングルトンのため、初期化後の状態を検証
        // setUp でUserDefaultsをクリアしているため、progress(for:1) は isUnlocked=true を返すはず
        let progress = ScoreService.shared.progress(for: 1)
        // 初期状態または保存された状態のどちらでも level1 はアンロック済み
        XCTAssertTrue(progress.isUnlocked, "ステージ1は最初からアンロックされている必要がある")
    }

    func testRecordClearUpdatesProgress() {
        ScoreService.shared.recordClear(levelId: 1, score: 100, stars: 3)
        let progress = ScoreService.shared.progress(for: 1)
        XCTAssertTrue(progress.isCleared, "クリア後はisCleared==trueになる必要がある")
        XCTAssertEqual(progress.bestScore, 100)
        XCTAssertEqual(progress.bestStars, 3)
    }

    func testRecordClearUnlocksNextLevel() {
        ScoreService.shared.recordClear(levelId: 1, score: 50, stars: 2)
        let next = ScoreService.shared.progress(for: 2)
        XCTAssertTrue(next.isUnlocked, "ステージ1クリア後にステージ2がアンロックされる必要がある")
    }

    func testBestScoreIsUpdatedOnlyIfHigher() {
        ScoreService.shared.recordClear(levelId: 3, score: 200, stars: 2)
        ScoreService.shared.recordClear(levelId: 3, score: 100, stars: 1)
        let progress = ScoreService.shared.progress(for: 3)
        XCTAssertEqual(progress.bestScore, 200, "低いスコアで上書きされてはならない")
        XCTAssertEqual(progress.bestStars, 2, "低いスターで上書きされてはならない")
    }

    func testBestScoreIsUpdatedIfHigher() {
        ScoreService.shared.recordClear(levelId: 4, score: 100, stars: 1)
        ScoreService.shared.recordClear(levelId: 4, score: 300, stars: 3)
        let progress = ScoreService.shared.progress(for: 4)
        XCTAssertEqual(progress.bestScore, 300, "高いスコアで更新される必要がある")
        XCTAssertEqual(progress.bestStars, 3)
    }

    func testLevel20ClearDoesNotUnlock21() {
        ScoreService.shared.recordClear(levelId: 20, score: 999, stars: 3)
        // ステージ21は存在しない（1〜20のみ）
        let outOfRange = ScoreService.shared.progress(for: 21)
        // progress(for:21)はLevelProgressのデフォルトを返す
        XCTAssertFalse(outOfRange.isUnlocked, "ステージ21は存在しないためアンロックされない")
    }
}

// MARK: - GameState Tests
final class GameStateTests: XCTestCase {

    func testInitialState() {
        let state = GameState()
        XCTAssertEqual(state.phase, .idle)
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.lives, 3)
        XCTAssertEqual(state.currentLevel, 1)
        XCTAssertEqual(state.totalBlocks, 0)
        XCTAssertEqual(state.destroyedBlocks, 0)
    }

    func testResetRestoresInitialValues() {
        var state = GameState()
        state.score = 500
        state.lives = 1
        state.phase = .playing
        state.destroyedBlocks = 10

        state.reset(level: 3)

        XCTAssertEqual(state.phase, .idle)
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.lives, 3)
        XCTAssertEqual(state.currentLevel, 3)
        XCTAssertEqual(state.destroyedBlocks, 0)
    }

    func testAddScore() {
        var state = GameState()
        state.addScore(10)
        state.addScore(20)
        XCTAssertEqual(state.score, 30)
    }

    func testLoseLifeDecrements() {
        var state = GameState()
        state.loseLife()
        XCTAssertEqual(state.lives, 2)
        XCTAssertNotEqual(state.phase, .gameOver)
    }

    func testLoseLifeGameOver() {
        var state = GameState()
        state.loseLife() // 2
        state.loseLife() // 1
        state.loseLife() // 0 -> gameOver
        XCTAssertEqual(state.lives, 0)
        XCTAssertEqual(state.phase, .gameOver)
    }

    func testLivesDoNotGoBelowZero() {
        var state = GameState()
        state.loseLife()
        state.loseLife()
        state.loseLife()
        state.loseLife() // 4回目は0のまま
        XCTAssertEqual(state.lives, 0)
    }

    func testIsCleared() {
        var state = GameState()
        state.totalBlocks = 5
        state.destroyedBlocks = 5
        XCTAssertTrue(state.isCleared)
    }

    func testIsNotClearedWhenBlocksRemain() {
        var state = GameState()
        state.totalBlocks = 5
        state.destroyedBlocks = 4
        XCTAssertFalse(state.isCleared)
    }

    func testIsNotClearedWhenTotalBlocksIsZero() {
        var state = GameState()
        state.totalBlocks = 0
        state.destroyedBlocks = 0
        XCTAssertFalse(state.isCleared, "ブロック数0のときはクリア扱いにならない")
    }

    func testStars3WhenLives3() {
        var state = GameState()
        state.lives = 3
        XCTAssertEqual(state.stars, 3)
    }

    func testStars2WhenLives2() {
        var state = GameState()
        state.lives = 2
        XCTAssertEqual(state.stars, 2)
    }

    func testStars1WhenLives1() {
        var state = GameState()
        state.lives = 1
        XCTAssertEqual(state.stars, 1)
    }

    func testRemainingBlocks() {
        var state = GameState()
        state.totalBlocks = 10
        state.destroyedBlocks = 3
        XCTAssertEqual(state.remainingBlocks, 7)
    }

    func testPhaseTransitionFromIdleToPlaying() {
        var state = GameState()
        XCTAssertEqual(state.phase, .idle)
        state.phase = .playing
        XCTAssertEqual(state.phase, .playing)
    }

    func testPhaseTransitionToPaused() {
        var state = GameState()
        state.phase = .playing
        state.phase = .paused
        XCTAssertEqual(state.phase, .paused)
    }

    func testPhaseTransitionToClear() {
        var state = GameState()
        state.phase = .playing
        state.phase = .clear
        XCTAssertEqual(state.phase, .clear)
    }
}

// MARK: - Block Tests
final class BlockTests: XCTestCase {

    func testBlockInitFromBlockData() {
        let data = BlockData(row: 2, col: 3, type: 2)
        let block = Block(data: data)
        XCTAssertEqual(block.row, 2)
        XCTAssertEqual(block.col, 3)
        XCTAssertEqual(block.hp, 2)
        XCTAssertEqual(block.type, .medium)
    }

    func testBlockInitDirectly() {
        let block = Block(row: 1, col: 5, hp: 3)
        XCTAssertEqual(block.row, 1)
        XCTAssertEqual(block.col, 5)
        XCTAssertEqual(block.hp, 3)
        XCTAssertEqual(block.type, .strong)
    }

    func testBlockIsAlive() {
        let block = Block(row: 0, col: 0, hp: 1)
        XCTAssertTrue(block.isAlive)
    }

    func testBlockIsNotAliveWhenHpZero() {
        var block = Block(row: 0, col: 0, hp: 1)
        block.hp = 0
        XCTAssertFalse(block.isAlive)
    }

    func testBlockHPDecrease() {
        var block = Block(row: 0, col: 0, hp: 3)
        block.hp -= 1
        XCTAssertEqual(block.hp, 2)
        XCTAssertTrue(block.isAlive)
    }

    func testBlockDestroyedAfter3Hits() {
        var block = Block(row: 0, col: 0, hp: 3)
        block.hp -= 1 // 2
        block.hp -= 1 // 1
        block.hp -= 1 // 0
        XCTAssertFalse(block.isAlive)
    }

    func testBlockColorAtHP3() {
        let block = Block(row: 0, col: 0, hp: 3)
        XCTAssertEqual(block.currentColor, BlockType.strong.color)
    }

    func testBlockColorAtHP2() {
        let block = Block(row: 0, col: 0, hp: 2)
        XCTAssertEqual(block.currentColor, BlockType.medium.color)
    }

    func testBlockColorAtHP1() {
        let block = Block(row: 0, col: 0, hp: 1)
        XCTAssertEqual(block.currentColor, BlockType.weak.color)
    }

    func testBlockTypeWeakPoints() {
        XCTAssertEqual(BlockType.weak.points, 10)
    }

    func testBlockTypeMediumPoints() {
        XCTAssertEqual(BlockType.medium.points, 20)
    }

    func testBlockTypeStrongPoints() {
        XCTAssertEqual(BlockType.strong.points, 30)
    }

    func testBlockTypeInitFromRawValue() {
        XCTAssertEqual(BlockType(rawValue: 1), .weak)
        XCTAssertEqual(BlockType(rawValue: 2), .medium)
        XCTAssertEqual(BlockType(rawValue: 3), .strong)
        XCTAssertNil(BlockType(rawValue: 0))
        XCTAssertNil(BlockType(rawValue: 4))
    }

    func testBlockWithInvalidTypeDefaultsToWeak() {
        let data = BlockData(row: 0, col: 0, type: 99)
        let block = Block(data: data)
        XCTAssertEqual(block.type, .weak, "無効なtype値はweakにフォールバックする")
    }

    func testLevelProgressUpdate() {
        var progress = LevelProgress(levelId: 1, isUnlocked: true)
        XCTAssertFalse(progress.isCleared)
        XCTAssertEqual(progress.bestScore, 0)
        XCTAssertEqual(progress.bestStars, 0)

        progress.update(score: 150, stars: 2)
        XCTAssertTrue(progress.isCleared)
        XCTAssertEqual(progress.bestScore, 150)
        XCTAssertEqual(progress.bestStars, 2)
    }
}
