import SpriteKit
import UIKit

extension GameScene {
    // MARK: - Touch入力処理

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePaddle(to: location.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePaddle(to: location.x)

        // アイドル状態でタッチムーブされたら発射
        if gameViewModel?.gameState.phase == .idle {
            gameViewModel?.startGame()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // タップでゲーム開始（アイドル状態の場合）
        if gameViewModel?.gameState.phase == .idle {
            gameViewModel?.startGame()
        } else {
            movePaddle(to: location.x)
        }
    }

    // パドルを指定X位置に移動
    func movePaddle(to x: CGFloat) {
        guard let paddle = paddleNode else { return }
        let halfPaddle = paddleWidth / 2
        let clampedX = max(halfPaddle, min(size.width - halfPaddle, x))

        // スムーズな移動
        let move = SKAction.moveTo(x: clampedX, duration: 0.02)
        move.timingMode = .easeOut
        paddle.run(move, withKey: "paddleMove")
    }
}
