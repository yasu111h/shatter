import SpriteKit

class GameScene: SKScene {
    weak var gameViewModel: GameViewModel?

    private var paddle: SKSpriteNode!
    private var ball: SKSpriteNode!
    private var blockNodes: [SKSpriteNode] = []
    private var totalBlocks = 0

    private let paddleCategory: UInt32 = 0x1 << 0
    private let ballCategory:   UInt32 = 0x1 << 1
    private let blockCategory:  UInt32 = 0x1 << 2
    private let wallCategory:   UInt32 = 0x1 << 3

    // MARK: - Setup

    func setupLevel(levelId: Int) {
        removeAllChildren()
        removeAllActions()
        blockNodes.removeAll()

        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1)

        setupWalls()
        setupPaddle()
        setupBall()

        let level = LevelLoader.load(levelId: levelId) ?? LevelLoader.fallback(levelId: levelId)
        setupBlocks(level: level)
    }

    private func setupWalls() {
        let body = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        body.friction = 0
        body.restitution = 1
        body.categoryBitMask = wallCategory
        self.physicsBody = body
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func setupPaddle() {
        let w = size.width * 0.28
        let h: CGFloat = 14
        paddle = SKSpriteNode(color: UIColor(red: 0, green: 0.898, blue: 1, alpha: 1),
                              size: CGSize(width: w, height: h))
        paddle.position = CGPoint(x: size.width / 2, y: 60)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.restitution = 1
        paddle.physicsBody?.categoryBitMask = paddleCategory
        paddle.physicsBody?.collisionBitMask = ballCategory
        addChild(paddle)
    }

    func setupBall() {
        if ball != nil { ball.removeFromParent() }
        let r: CGFloat = 8
        ball = SKSpriteNode(color: .white, size: CGSize(width: r*2, height: r*2))
        ball.position = CGPoint(x: size.width / 2, y: paddle.position.y + 30)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = blockCategory | paddleCategory
        ball.physicsBody?.collisionBitMask = wallCategory | paddleCategory | blockCategory
        addChild(ball)
    }

    private func setupBlocks(level: LevelData) {
        let cols = level.gridColumns
        let rows = level.blockLayout.count
        let padding: CGFloat = 8
        let topMargin: CGFloat = size.height * 0.15
        let blockW = (size.width - padding * CGFloat(cols + 1)) / CGFloat(cols)
        let blockH: CGFloat = 22

        totalBlocks = 0

        for (r, row) in level.blockLayout.enumerated() {
            for (c, val) in row.enumerated() {
                guard val > 0 else { continue }
                let hp = min(val, 3)
                let x = padding + CGFloat(c) * (blockW + padding) + blockW / 2
                let y = size.height - topMargin - CGFloat(r) * (blockH + padding) - blockH / 2

                let color = blockColor(hp: hp)
                let node = SKSpriteNode(color: color, size: CGSize(width: blockW, height: blockH))
                node.position = CGPoint(x: x, y: y)
                node.name = "block_\(r)_\(c)_hp\(hp)"
                node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                node.physicsBody?.isDynamic = false
                node.physicsBody?.categoryBitMask = blockCategory
                node.physicsBody?.collisionBitMask = ballCategory

                // HP数字ラベル
                if hp > 1 {
                    let label = SKLabelNode(text: "\(hp)")
                    label.fontSize = 12
                    label.fontName = "Courier-Bold"
                    label.fontColor = .white
                    label.verticalAlignmentMode = .center
                    label.name = "label"
                    node.addChild(label)
                }

                addChild(node)
                blockNodes.append(node)
                totalBlocks += 1
            }
        }
    }

    private func blockColor(hp: Int) -> UIColor {
        switch hp {
        case 3: return UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1)
        case 2: return UIColor(red: 1, green: 0.58, blue: 0, alpha: 1)
        default: return UIColor(red: 0, green: 0.898, blue: 1, alpha: 1)
        }
    }

    // MARK: - Touch → ゲーム開始

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let vm = gameViewModel else { return }
        if vm.gameState.phase == .idle {
            vm.gameState.phase = .playing
            launchBall()
        }
        movePaddle(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        movePaddle(touches: touches)
    }

    func movePaddle(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        let half = paddle.size.width / 2
        paddle.position.x = max(half, min(size.width - half, x))
    }

    func launchBall() {
        let speed: CGFloat = 350
        let angle = CGFloat.random(in: 50...130) * .pi / 180
        let dx = speed * cos(angle)
        let dy = speed * sin(angle)
        ball.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        guard let vm = gameViewModel, vm.gameState.phase == .playing else { return }
        // ボールが画面下に落ちたら残機減少
        if ball.position.y < -20 {
            vm.loseLife()
            if vm.gameState.phase != .gameOver {
                resetBall()
            }
        }
        // 速度の正規化
        normalizeBallSpeed()
    }

    private func resetBall() {
        ball.physicsBody?.velocity = .zero
        ball.position = CGPoint(x: paddle.position.x, y: paddle.position.y + 30)
        gameViewModel?.gameState.phase = .idle
    }

    private func normalizeBallSpeed() {
        guard let body = ball.physicsBody else { return }
        let speed: CGFloat = 350
        let v = body.velocity
        let current = sqrt(v.dx*v.dx + v.dy*v.dy)
        guard current > 0 else { return }
        body.velocity = CGVector(dx: v.dx / current * speed, dy: v.dy / current * speed)
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == ballCategory ? contact.bodyB : contact.bodyA
        guard other.categoryBitMask == blockCategory,
              let node = other.node as? SKSpriteNode,
              let name = node.name, name.hasPrefix("block_") else { return }

        // HP取り出し
        let parts = name.components(separatedBy: "_hp")
        guard parts.count == 2, var hp = Int(parts[1]) else { return }

        hp -= 1
        gameViewModel?.addScore(10)

        if hp <= 0 {
            node.removeFromParent()
            blockNodes.removeAll { $0 === node }
            if blockNodes.isEmpty { gameViewModel?.stageClear() }
        } else {
            node.name = "\(parts[0])_hp\(hp)"
            node.color = blockColor(hp: hp)
            if let label = node.childNode(withName: "label") as? SKLabelNode {
                if hp > 1 { label.text = "\(hp)" } else { label.removeFromParent() }
            }
        }
    }
}
