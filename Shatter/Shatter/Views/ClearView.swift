import SwiftUI

struct ClearView: View {
    let score: Int
    let stars: Int
    let levelId: Int
    let onNext: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("CLEAR!")
                    .font(.custom("Courier-Bold", size: 36))
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .tracking(6)

                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= stars ? "star.fill" : "star")
                            .foregroundColor(i <= stars ? .yellow : .gray)
                            .font(.system(size: 28))
                    }
                }

                Text(String(format: "SCORE  %06d", score))
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.white)
                    .tracking(2)
                    .padding(.top, 8)

                if levelId < 20 {
                    actionButton("NEXT STAGE", color: Color(hex: "#00E5FF"), action: onNext)
                }
                actionButton("RETRY", color: .white.opacity(0.7), action: onRestart)
                actionButton("EXIT", color: .white.opacity(0.4), action: onExit)
            }
        }
    }

    func actionButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Courier-Bold", size: 15))
                .foregroundColor(color)
                .tracking(3)
                .frame(width: 200, height: 44)
                .overlay(RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.5), lineWidth: 1))
        }
    }
}
