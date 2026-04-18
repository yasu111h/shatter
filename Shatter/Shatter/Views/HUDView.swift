import SwiftUI

struct HUDView: View {
    let score: Int
    let lives: Int
    let onPause: () -> Void

    var body: some View {
        HStack {
            // 残機
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Image(systemName: i < lives ? "circle.fill" : "circle")
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .font(.system(size: 10))
                }
            }
            .padding(.leading, 16)

            Spacer()

            // スコア
            Text(String(format: "%06d", score))
                .font(.custom("Courier-Bold", size: 16))
                .foregroundColor(.white)
                .tracking(2)

            Spacer()

            // ポーズ
            Button(action: onPause) {
                Image(systemName: "pause.fill")
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .font(.system(size: 18))
            }
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.6))
    }
}
