import SwiftUI

struct TitleView: View {
    let onStart: () -> Void
    let onSettings: () -> Void

    @State private var glowOpacity: Double = 0.5
    @State private var showSubtitle = false

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            // 背景グリッド
            GeometryReader { geo in
                Path { path in
                    let cols = 12
                    let rows = 20
                    let w = geo.size.width / CGFloat(cols)
                    let h = geo.size.height / CGFloat(rows)
                    for col in 0...cols {
                        path.move(to: CGPoint(x: CGFloat(col) * w, y: 0))
                        path.addLine(to: CGPoint(x: CGFloat(col) * w, y: geo.size.height))
                    }
                    for row in 0...rows {
                        path.move(to: CGPoint(x: 0, y: CGFloat(row) * h))
                        path.addLine(to: CGPoint(x: geo.size.width, y: CGFloat(row) * h))
                    }
                }
                .stroke(Color(hex: "#00E5FF").opacity(0.06), lineWidth: 0.5)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // タイトル
                VStack(spacing: 8) {
                    Text("SHATTER")
                        .font(.custom("Courier-Bold", size: 52))
                        .foregroundColor(.white)
                        .tracking(12)
                        .shadow(color: Color(hex: "#00E5FF").opacity(glowOpacity), radius: 20)
                        .shadow(color: Color(hex: "#00E5FF").opacity(glowOpacity * 0.5), radius: 40)

                    Text("BLOCK BREAKER")
                        .font(.custom("Courier", size: 13))
                        .foregroundColor(Color(hex: "#00E5FF").opacity(0.7))
                        .tracking(6)
                        .opacity(showSubtitle ? 1 : 0)
                }

                Spacer()

                // ボタン群
                VStack(spacing: 16) {
                    Button(action: onStart) {
                        Text("START GAME")
                            .font(.custom("Courier-Bold", size: 18))
                            .foregroundColor(Color(hex: "#0A0A0A"))
                            .tracking(4)
                            .frame(width: 240, height: 52)
                            .background(Color(hex: "#00E5FF"))
                            .cornerRadius(4)
                    }

                    Button(action: onSettings) {
                        Text("SETTINGS")
                            .font(.custom("Courier", size: 15))
                            .foregroundColor(Color(hex: "#00E5FF").opacity(0.7))
                            .tracking(4)
                            .frame(width: 240, height: 44)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#00E5FF").opacity(0.4), lineWidth: 1))
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                showSubtitle = true
            }
        }
    }
}
