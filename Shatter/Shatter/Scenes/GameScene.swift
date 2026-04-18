import SpriteKit
import Foundation

// 物理カテゴリビットマスク
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let ball:    UInt32 = 0b0001
    static let paddle:  UInt32 = 0b0010
    static let block:   UInt32 = 0b0100
    static let wall:    UInt32 = 0b1000
    static let bottom:  UInt32 = 0b10000
}

class GameScene: SKScene {
    // MARK: - Properties
    weak var gameViewModel: GameViewModel?

    // ノード
    var ballNode: SKSpriteNode?
    var paddleNode: SKSpriteNode?
    var blockNodes: [SKSpriteNode] = []

    // ゲームデータ
    var blocks: [Block] = []
    var levelData: LevelData?

    // 定数
    let paddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 14
    let ballRadius: CGFloat = 10
    let ballSpeed: CGFloat = 420
    let blockRows = 5
    let blockCols = 8

    // MARK: - Setup
    override func didMove(to view: SKView) {
        setupScene()
    }

    func setupScene() {
        backgroundColor = SKColor(hex: "#0A0A0A")
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupWalls()
        setupPaddle()
    }

    func loadLevel(_ level: LevelData) {
        self.levelData = level
        removeAllBlocks()
        setupBlocks(from: level)
        resetBall()
    }

    // MARK: - Walls (境界壁)
    func setupWalls() {
        // 上・左・右の壁
        let wallBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: -size.height, width: size.width, height: size.height * 2))
        wallBody.categoryBitMask = PhysicsCategory.wall
        wallBody.collisionBitMask = PhysicsCategory.ball
        wallBody.restitution = 1.0
        wallBody.friction = 0
        let wallNode = SKNode()
        wallNode.physicsBody = wallBody
        addChild(wallNode)

        // ボトム検知ライン（目に見えない）
        let bottomNode = SKNode()
        bottomNode.position = CGPoint(x: size.width / 2, y: -20)
        let bottomBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        bottomBody.isDynamic = false
        bottomBody.categoryBitMask = PhysicsCategory.bottom
        bottomBody.contactTestBitMask = PhysicsCategory.ball
        bottomBody.collisionBitMask = PhysicsCategory.none
        bottomNode.physicsBody = bottomBody
        addChild(bottomNode)
    }

    // MARK: - Paddle
    func setupPaddle() {
        let paddle = SKSpriteNode(color: SKColor(hex: "#00E5FF"), size: CGSize(width: paddleWidth, height: paddleHeight))
        paddle.position = CGPoint(x: size.width / 2, y: 80)

        let body = SKPhysicsBody(rectangleOf: paddle.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        body.restitution = 1.0
        body.friction = 0
        paddle.physicsBody = body
        addChild(paddle)
        paddleNode = paddle

        // パドルの光彩エフェクト
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 6])
        let glowSprite = SKSpriteNode(color: SKColor(hex: "#00E5FF").withAlphaComponent(0.5),
                                      size: CGSize(width: paddleWidth + 10, height: paddleHeight + 10))
        glow.addChild(glowSprite)
        paddle.addChild(glow)
    }

    // MARK: - Ball
    func setupBall() {
        guard ballNode == nil else { return }
        let ball = SKSpriteNode(color: .white, size: CGSize(width: ballRadius * 2, height: ballRadius * 2))
        ball.position = CGPoint(x: size.width / 2, y: 110)

        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.restitution = 1.0
        body.friction = 0
        body.linearDamping = 0
        body.angularDamping = 0
        body.categoryBitMask = PhysicsCategory.ball
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.block
        body.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.paddle | PhysicsCategory.bottom
        ball.physicsBody = body
        addChild(ball)
        ballNode = ball
    }

    func resetBall() {
        ballNode?.removeFromParent()
        ballNode = nil
        setupBall()
    }

    func launchBall() {
        guard let ball = ballNode else { return }
        // 斜め上方向に発射
        let angle = CGFloat.random(in: (CGFloat.pi / 4)...(CGFloat.pi * 3 / 4))
        let vx = cos(angle) * ballSpeed
        let vy = sin(angle) * ballSpeed
        ball.physicsBody?.velocity = CGVector(dx: vx, dy: vy)
    }

    // MARK: - Blocks
    func setupBlocks(from level: LevelData) {
        blocks = level.blocks.map { Block(data: $0) }
        let safeAreaTop: CGFloat = 100
        let blockWidth: CGFloat = (size.width - 20) / CGFloat(blockCols)
        let blockHeight: CGFloat = 28
        let blockSpacing: CGFloat = 4
        let startY = size.height - safeAreaTop

        for (index, blockData) in level.blocks.enumerated() {
            let col = blockData.col
            let row = blockData.row
            let x = 10 + CGFloat(col) * blockWidth + blockWidth / 2
            let y = startY - CGFloat(row) * (blockHeight + blockSpacing) - blockHeight / 2

            let block = SKSpriteNode(
                color: blocks[index].currentColor,
                size: CGSize(width: blockWidth - blockSpacing, height: blockHeight)
            )
            block.position = CGPoint(x: x, y: y)
            block.name = "block_\(index)"

            // HP表示ラベル
            if blocks[index].hp > 1 {
                let label = SKLabelNode(text: "\(blocks[index].hp)")
                label.fontName = "Courier-Bold"
                label.fontSize = 14
                label.fontColor = .white
                label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = .center
                label.name = "hpLabel"
                block.addChild(label)
            }

            let body = SKPhysicsBody(rectangleOf: block.size)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.block
            body.contactTestBitMask = PhysicsCategory.ball
            body.collisionBitMask = PhysicsCategory.ball
            body.restitution = 1.0
            body.friction = 0
            block.physicsBody = body

            addChild(block)
            blockNodes.append(block)
            blocks[index].node = block
        }
        gameViewModel?.onTotalBlocksSet(level.blocks.count)
    }

    func removeAllBlocks() {
        blockNodes.forEach { $0.removeFromParent() }
        blockNodes = []
        blocks = []
    }

    // ブロックにダメージを与える
    func damageBlock(node: SKSpriteNode) {
        guard let name = node.name,
              let idxStr = name.split(separator: "_").last,
              let idx = Int(idxStr),
              idx < blocks.count else { return }

        blocks[idx].hp -= 1
        let hp = blocks[idx].hp
        AudioService.shared.playSE(AudioService.SE.hit)

        if hp <= 0 {
            // ブロック破壊
            let points = blocks[idx].type.points
            gameViewModel?.onScoreAdded(points)
            gameViewModel?.onBlockDestroyed()
            AudioService.shared.playSE(AudioService.SE.blockBreak)

            // 破壊エフェクト
            spawnBreakParticles(at: node.position, color: blocks[idx].currentColor)
            node.removeFromParent()
        } else {
            // HP減少後の色・ラベル更新
            node.color = blocks[idx].currentColor
            if let label = node.childNode(withName: "hpLabel") as? SKLabelNode {
                label.text = hp > 1 ? "\(hp)" : ""
            }
            // ヒットエフェクト
            let flash = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
                SKAction.colorize(with: blocks[idx].currentColor, colorBlendFactor: 1.0, duration: 0.05)
            ])
            node.run(flash)
        }
    }

    // パーティクルエフェクト（ブロック破壊時）
    func spawnBreakParticles(at position: CGPoint, color: SKColor) {
        for _ in 0..<8 {
            let particle = SKSpriteNode(color: color, size: CGSize(width: 5, height: 5))
            particle.position = position
            addChild(particle)

            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let speed = CGFloat.random(in: 60...150)
            let dx = cos(angle) * speed
            let dy = sin(angle) * speed
            let duration = TimeInterval.random(in: 0.3...0.6)

            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(by: CGVector(dx: dx, dy: dy), duration: duration),
                    SKAction.fadeOut(withDuration: duration),
                    SKAction.scale(to: 0, duration: duration)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        guard let ball = ballNode, let body = ball.physicsBody else { return }

        // ボールの速度を一定に保つ
        let velocity = body.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        if speed > 0 && abs(speed - ballSpeed) > 20 {
            let factor = ballSpeed / speed
            body.velocity = CGVector(dx: velocity.dx * factor, dy: velocity.dy * factor)
        }

        // ボールが完全に画面外に出たら（フォールバック）
        if ball.position.y < -50 {
            handleBallLost()
        }
    }

    func handleBallLost() {
        ballNode?.physicsBody?.velocity = .zero
        ballNode?.removeFromParent()
        ballNode = nil
        AudioService.shared.playSE(AudioService.SE.ballLost)
        gameViewModel?.onLifeLost()

        if gameViewModel?.gameState.phase != .gameOver {
            // 少し待ってボールをリセット
            run(SKAction.sequence([
                SKAction.wait(forDuration: 0.8),
                SKAction.run { [weak self] in
                    self?.resetBall()
                    self?.gameViewModel?.gameState.phase = .idle
                }
            ]))
        } else {
            AudioService.shared.playSE(AudioService.SE.gameOver)
            AudioService.shared.stopBGM()
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // ボールがボトムラインに触れた
        if (bodyA.categoryBitMask == PhysicsCategory.ball && bodyB.categoryBitMask == PhysicsCategory.bottom) ||
           (bodyB.categoryBitMask == PhysicsCategory.ball && bodyA.categoryBitMask == PhysicsCategory.bottom) {
            handleBallLost()
            return
        }

        // ボールがブロックに当たった
        let blockNode: SKSpriteNode?
        if bodyA.categoryBitMask == PhysicsCategory.block {
            blockNode = bodyA.node as? SKSpriteNode
        } else if bodyB.categoryBitMask == PhysicsCategory.block {
            blockNode = bodyB.node as? SKSpriteNode
        } else {
            blockNode = nil
        }

        if let block = blockNode {
            damageBlock(node: block)
        }

        // パドルヒット時SE
        if (bodyA.categoryBitMask == PhysicsCategory.paddle || bodyB.categoryBitMask == PhysicsCategory.paddle) {
            AudioService.shared.playSE(AudioService.SE.paddleHit)
        }
    }
}
