import SwiftUI

struct HUDView: View {
    let score: Int
    let lives: Int
    let onPause: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            // スコア
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.custom("Courier", size: 10))
                    .foregroundColor(Color(hex: "#00E5FF").opacity(0.6))
                    .tracking(2)
                Text("\(score)")
                    .font(.custom("Courier-Bold", size: 22))
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .monospacedDigit()
            }

            Spacer()

            // 残機（ハートアイコン）
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(i < lives ? Color(hex: "#FF3B30") : Color.gray.opacity(0.3))
                }
            }

            Spacer()

            // ポーズボタン
            Button(action: onPause) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "#1A1A1A"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#00E5FF").opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(hex: "#0A0A0A").opacity(0.9)
        )
    }
}
