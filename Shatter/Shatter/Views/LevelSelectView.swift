import SwiftUI

struct LevelSelectView: View {
    let onSelect: (Int) -> Void
    let onBack: () -> Void

    @State private var progresses = ScoreService.shared.progresses

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "#00E5FF"))
                            .font(.system(size: 18))
                    }
                    Spacer()
                    Text("SELECT STAGE")
                        .font(.custom("Courier-Bold", size: 16))
                        .foregroundColor(.white)
                        .tracking(4)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider().background(Color(hex: "#00E5FF").opacity(0.2))

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(1...20, id: \.self) { levelId in
                            levelCell(levelId: levelId)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            progresses = ScoreService.shared.progresses
        }
    }

    @ViewBuilder
    func levelCell(levelId: Int) -> some View {
        let unlocked = ScoreService.shared.isUnlocked(levelId)
        let stars = ScoreService.shared.bestStars(for: levelId)

        Button(action: {
            if unlocked { onSelect(levelId) }
        }) {
            ZStack {
                if unlocked {
                    // 解放済み: 塗りつぶし背景
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "#00E5FF").opacity(0.5), lineWidth: 1)
                        )
                } else {
                    // ロック済み: 赤みがかった枠のみ
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "#FF3B3B").opacity(0.6), lineWidth: 1.5)
                        )
                }

                VStack(spacing: 4) {
                    if unlocked {
                        Text(String(format: "%02d", levelId))
                            .font(.custom("Courier-Bold", size: 22))
                            .foregroundColor(.white)

                        // スター表示
                        HStack(spacing: 2) {
                            ForEach(1...3, id: \.self) { i in
                                Image(systemName: i <= stars ? "star.fill" : "star")
                                    .font(.system(size: 7))
                                    .foregroundColor(i <= stars ? .yellow : Color.white.opacity(0.2))
                            }
                        }
                    } else {
                        // ロック済みはアイコン + ステージ番号（暗め）
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#FF3B3B").opacity(0.8))

                        Text(String(format: "%02d", levelId))
                            .font(.custom("Courier", size: 14))
                            .foregroundColor(Color.white.opacity(0.25))
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .disabled(!unlocked)
    }
}
