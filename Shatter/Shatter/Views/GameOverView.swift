import SwiftUI

struct GameOverView: View {
    let score: Int
    let levelId: Int
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("GAME OVER")
                    .font(.custom("Courier-Bold", size: 30))
                    .foregroundColor(Color(hex: "#FF3B3B"))
                    .tracking(4)

                Text(String(format: "SCORE  %06d", score))
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.white)
                    .tracking(2)

                Button(action: onRestart) {
                    Text("RETRY")
                        .font(.custom("Courier-Bold", size: 16))
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .tracking(3)
                        .frame(width: 180, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: "#00E5FF").opacity(0.6), lineWidth: 1))
                }
                Button(action: onExit) {
                    Text("EXIT")
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                }
            }
        }
    }
}
