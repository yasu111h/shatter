import SwiftUI

struct TitleView: View {
    @Binding var showLevelSelect: Bool
    @Binding var showSettings: Bool
    @State private var animatePulse = false
    @State private var animateGlow = false

    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#0A0A0A").ignoresSafeArea()

            // グリッドパターン背景
            GridBackgroundView()
                .opacity(0.15)

            VStack(spacing: 0) {
                Spacer()

                // タイトルロゴ
                VStack(spacing: 8) {
                    Text("SHATTER")
                        .font(.custom("Courier-Bold", size: 56))
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .shadow(color: Color(hex: "#00E5FF").opacity(animateGlow ? 0.9 : 0.3), radius: animateGlow ? 20 : 8)
                        .scaleEffect(animatePulse ? 1.02 : 1.0)

                    Text("BREAK · SHATTER · CONQUER")
                        .font(.custom("Courier", size: 13))
                        .foregroundColor(Color(hex: "#00E5FF").opacity(0.6))
                        .tracking(3)
                }
                .padding(.bottom, 80)

                Spacer()

                // ボタン群
                VStack(spacing: 16) {
                    TitleButton(title: "PLAY", isPrimary: true) {
                        showLevelSelect = true
                    }

                    TitleButton(title: "SETTINGS", isPrimary: false) {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
        .fullScreenCover(isPresented: $showLevelSelect) {
            LevelSelectView(showLevelSelect: $showLevelSelect)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// タイトル画面用ボタン
struct TitleButton: View {
    let title: String
    let isPrimary: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Courier-Bold", size: 18))
                .tracking(4)
                .foregroundColor(isPrimary ? Color(hex: "#0A0A0A") : Color(hex: "#00E5FF"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isPrimary ?
                    Color(hex: "#00E5FF") :
                    Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#00E5FF"), lineWidth: isPrimary ? 0 : 1.5)
                )
                .cornerRadius(4)
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                }
        )
    }
}

// グリッド背景
struct GridBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let spacing: CGFloat = 40
                var path = Path()

                // 縦線
                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }

                // 横線
                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }

                context.stroke(path, with: .color(Color(hex: "#00E5FF")), lineWidth: 0.5)
            }
        }
    }
}

// Color hex拡張
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
