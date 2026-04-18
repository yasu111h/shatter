import SwiftUI

struct ClearView: View {
    let score: Int
    let stars: Int
    let levelId: Int
    let onNext: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    @State private var showStars = false
    @State private var starScale: [CGFloat] = [0, 0, 0]
    @State private var scoreOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 0) {
                // STAGE CLEAR テキスト
                VStack(spacing: 6) {
                    Text("STAGE CLEAR")
                        .font(.custom("Courier-Bold", size: 30))
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .tracking(4)

                    Text(String(format: "STAGE %02d", levelId))
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(Color(hex: "#00E5FF").opacity(0.6))
                        .tracking(3)
                }
                .padding(.bottom, 36)

                // スター評価
                HStack(spacing: 16) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 44))
                            .foregroundColor(i < stars ? Color(hex: "#FFD700") : Color.gray.opacity(0.2))
                            .scaleEffect(starScale[i])
                            .shadow(color: i < stars ? Color(hex: "#FFD700").opacity(0.6) : .clear, radius: 8)
                    }
                }
                .padding(.bottom, 32)

                // スコア
                VStack(spacing: 4) {
                    Text("SCORE")
                        .font(.custom("Courier", size: 12))
                        .foregroundColor(Color(hex: "#00E5FF").opacity(0.6))
                        .tracking(3)
                    Text("\(score)")
                        .font(.custom("Courier-Bold", size: 36))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .opacity(scoreOpacity)
                .padding(.bottom, 44)

                // ボタン群
                VStack(spacing: 14) {
                    if levelId < 20 {
                        ClearButton(title: "NEXT STAGE", icon: "arrow.right", isPrimary: true, action: onNext)
                    }
                    ClearButton(title: "RETRY", icon: "arrow.counterclockwise", isPrimary: false, action: onRestart)
                    ClearButton(title: "STAGE SELECT", icon: "list.bullet", isPrimary: false, action: onExit)
                }
                .frame(width: 240)
            }
        }
        .onAppear {
            animateStars()
        }
    }

    func animateStars() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3 + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    starScale[i] = i < stars ? 1.2 : 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        starScale[i] = 1.0
                    }
                }
            }
        }
        withAnimation(.easeIn(duration: 0.4).delay(1.0)) {
            scoreOpacity = 1.0
        }
    }
}

struct ClearButton: View {
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
            .foregroundColor(isPrimary ? Color(hex: "#0A0A0A") : Color(hex: "#00E5FF"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isPrimary ? Color(hex: "#00E5FF") : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(hex: "#00E5FF"), lineWidth: isPrimary ? 0 : 1.5)
            )
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
