import SwiftUI
import SpriteKit

struct GameView: View {
    let levelId: Int
    let onExit: () -> Void

    @StateObject private var viewModel = GameViewModel()
    @State private var showPause = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "#0A0A0A").ignoresSafeArea()

                VStack(spacing: 0) {
                    // HUD
                    HUDView(
                        score: viewModel.gameState.score,
                        lives: viewModel.gameState.lives,
                        onPause: {
                            viewModel.togglePause()
                            showPause.toggle()
                        }
                    )
                    .frame(height: 60)

                    // ゲームシーン
                    if let scene = viewModel.scene {
                        SpriteView(scene: scene)
                            .ignoresSafeArea(edges: .bottom)
                    }
                }

                // アイドル状態のガイドテキスト
                if viewModel.gameState.phase == .idle {
                    VStack {
                        Spacer()
                        Text("TAP TO LAUNCH")
                            .font(.custom("Courier-Bold", size: 16))
                            .foregroundColor(Color(hex: "#00E5FF").opacity(0.8))
                            .tracking(4)
                            .padding(.bottom, 130)
                    }
                }

                // ポーズオーバーレイ
                if viewModel.gameState.phase == .paused {
                    PauseOverlayView(
                        onResume: {
                            viewModel.togglePause()
                            showPause = false
                        },
                        onRestart: {
                            viewModel.restart()
                            showPause = false
                        },
                        onExit: {
                            AudioService.shared.stopBGM()
                            onExit()
                        }
                    )
                    .transition(.opacity)
                }

                // クリア画面
                if viewModel.gameState.phase == .clear {
                    ClearView(
                        score: viewModel.gameState.score,
                        stars: viewModel.gameState.stars,
                        levelId: viewModel.gameState.currentLevel,
                        onNext: {
                            viewModel.nextLevel()
                        },
                        onRestart: {
                            viewModel.restart()
                        },
                        onExit: {
                            AudioService.shared.stopBGM()
                            onExit()
                        }
                    )
                    .transition(.opacity)
                }

                // ゲームオーバー画面
                if viewModel.gameState.phase == .gameOver {
                    GameOverView(
                        score: viewModel.gameState.score,
                        levelId: viewModel.gameState.currentLevel,
                        onRestart: {
                            viewModel.restart()
                        },
                        onExit: {
                            AudioService.shared.stopBGM()
                            onExit()
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            viewModel.setupScene(levelId: levelId, size: sceneSize(in: geo))
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState.phase)
    }

    func sceneSize(in geometry: GeometryProxy) -> CGSize {
        return CGSize(width: geometry.size.width, height: geometry.size.height - 60)
    }
}
