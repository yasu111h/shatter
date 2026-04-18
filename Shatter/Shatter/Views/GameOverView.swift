import SwiftUI

struct GameOverView: View {
    let score: Int
    let levelId: Int
    let onRestart: () -> Void
    let onExit: () -> Void

    @State private var titleOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.7
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.88).ignoresSafeArea()

            VStack(spacing: 0) {
                // GAME OVER テキスト
                VStack(spacing: 8) {
                    Text("GAME OVER")
                        .font(.custom("Courier-Bold", size: 36))
                        .foregroundColor(Color(hex: "#FF3B30"))
                        .tracking(4)
                        .shadow(color: Color(hex: "#FF3B30").opacity(0.6), radius: 12)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Text(String(format: "STAGE %02d", levelId))
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .tracking(3)
                        .opacity(contentOpacity)
                }
                .padding(.bottom, 40)

                // スコア
                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.custom("Courier", size: 12))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .tracking(3)
                    Text("\(score)")
                        .font(.custom("Courier-Bold", size: 36))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .opacity(contentOpacity)
                .padding(.bottom, 44)

                // ボタン群
                VStack(spacing: 14) {
                    GameOverButton(title: "RETRY", icon: "arrow.counterclockwise", isPrimary: true, action: onRestart)
                    GameOverButton(title: "STAGE SELECT", icon: "list.bullet", isPrimary: false, action: onExit)
                }
                .frame(width: 240)
                .opacity(contentOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                titleOpacity = 1.0
                titleScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
                contentOpacity = 1.0
            }
        }
    }
}

struct GameOverButton: View {
    let title: String
    let icon: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.custom("Courier-Bold", size: 15))
                    .tracking(2)
            }
            .foregroundColor(isPrimary ? .white : Color(hex: "#FF3B30"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isPrimary ? Color(hex: "#FF3B30") : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(hex: "#FF3B30"), lineWidth: isPrimary ? 0 : 1.5)
            )
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
