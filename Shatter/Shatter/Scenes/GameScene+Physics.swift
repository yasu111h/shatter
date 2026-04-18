import SpriteKit

extension GameScene {
    // MARK: - 物理演算補助

    // ボールの速度ベクトルを正規化して一定速に保つ
    func normalizeBallVelocity() {
        guard let ball = ballNode, let body = ball.physicsBody else { return }
        let v = body.velocity
        let currentSpeed = sqrt(v.dx * v.dx + v.dy * v.dy)
        guard currentSpeed > 0 else { return }
        let factor = ballSpeed / currentSpeed
        body.velocity = CGVector(dx: v.dx * factor, dy: v.dy * factor)
    }

    // ボールが水平・垂直方向に固まった場合のリカバリ
    func recoverBallAngle() {
        guard let ball = ballNode, let body = ball.physicsBody else { return }
        let v = body.velocity
        let angle = atan2(v.dy, v.dx)
        let tooHorizontal = abs(sin(angle)) < 0.15
        let tooVertical = abs(cos(angle)) < 0.15

        if tooHorizontal {
            let sign: CGFloat = v.dy >= 0 ? 1 : -1
            body.velocity = CGVector(dx: v.dx, dy: sign * ballSpeed * 0.3)
            normalizeBallVelocity()
        }

        if tooVertical {
            let sign: CGFloat = v.dx >= 0 ? 1 : -1
            body.velocity = CGVector(dx: sign * ballSpeed * 0.3, dy: v.dy)
            normalizeBallVelocity()
        }
    }

    // パドルで跳ね返る際に角度を調整（パドルの端に当たるほど外側に飛ぶ）
    func adjustBallAfterPaddleHit(contact: SKPhysicsContact) {
        guard let paddle = paddleNode, let ball = ballNode,
              let ballBody = ball.physicsBody else { return }

        let hitX = contact.contactPoint.x
        let paddleCenterX = paddle.position.x
        let halfWidth = paddleWidth / 2

        let offset = (hitX - paddleCenterX) / halfWidth  // -1.0 〜 1.0
        let maxAngle: CGFloat = CGFloat.pi / 3  // 最大60度
        let angle = CGFloat.pi / 2 - offset * maxAngle  // 真上を基準に角度調整
        let dy = sin(angle) * ballSpeed
        let dx = cos(angle) * ballSpeed
        ballBody.velocity = CGVector(dx: dx, dy: dy)
    }
}
