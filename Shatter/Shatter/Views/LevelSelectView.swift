import SwiftUI

struct LevelSelectView: View {
    @Binding var showLevelSelect: Bool
    @ObservedObject private var scoreService = ScoreService.shared
    @State private var selectedLevel: Int? = nil
    @State private var showGame = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: { showLevelSelect = false }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("BACK")
                                .font(.custom("Courier-Bold", size: 14))
                        }
                        .foregroundColor(Color(hex: "#00E5FF"))
                    }
                    Spacer()
                    Text("SELECT STAGE")
                        .font(.custom("Courier-Bold", size: 18))
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .tracking(3)
                    Spacer()
                    // バランス用
                    Color.clear.frame(width: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)

                // ステージグリッド
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(1...20, id: \.self) { level in
                            let progress = scoreService.progress(for: level)
                            LevelCell(
                                levelId: level,
                                isUnlocked: progress.isUnlocked,
                                isCleared: progress.isCleared,
                                stars: progress.bestStars
                            ) {
                                if progress.isUnlocked {
                                    selectedLevel = level
                                    showGame = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            if let level = selectedLevel {
                GameView(levelId: level, onExit: {
                    showGame = false
                })
            }
        }
    }
}

struct LevelCell: View {
    let levelId: Int
    let isUnlocked: Bool
    let isCleared: Bool
    let stars: Int
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isUnlocked ? Color(hex: "#1A1A1A") : Color(hex: "#111111"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isUnlocked ? Color(hex: "#00E5FF").opacity(0.6) : Color(hex: "#333333"),
                                    lineWidth: 1
                                )
                        )

                    if isUnlocked {
                        VStack(spacing: 4) {
                            Text(String(format: "%02d", levelId))
                                .font(.custom("Courier-Bold", size: 24))
                                .foregroundColor(Color(hex: "#00E5FF"))

                            // スター表示
                            if isCleared {
                                HStack(spacing: 2) {
                                    ForEach(1...3, id: \.self) { i in
                                        Image(systemName: i <= stars ? "star.fill" : "star")
                                            .font(.system(size: 10))
                                            .foregroundColor(i <= stars ? Color(hex: "#FFD700") : Color.gray.opacity(0.4))
                                    }
                                }
                            }
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#333333"))
                    }
                }
                .frame(height: 80)
                .scaleEffect(isPressed ? 0.94 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isUnlocked {
                        withAnimation(.easeInOut(duration: 0.08)) { isPressed = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                }
        )
    }
}
