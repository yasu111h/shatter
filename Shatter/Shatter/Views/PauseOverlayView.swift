import SwiftUI

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 0) {
                // タイトル
                Text("PAUSED")
                    .font(.custom("Courier-Bold", size: 32))
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .tracking(6)
                    .padding(.bottom, 40)

                // ボタン群
                VStack(spacing: 14) {
                    PauseButton(title: "RESUME", icon: "play.fill", isPrimary: true, action: onResume)
                    PauseButton(title: "RESTART", icon: "arrow.counterclockwise", isPrimary: false, action: onRestart)
                    PauseButton(title: "EXIT", icon: "xmark", isPrimary: false, action: onExit)
                }
                .frame(width: 240)
            }
        }
    }
}

struct PauseButton: View {
    let title: String
    let icon: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.custom("Courier-Bold", size: 16))
                    .tracking(3)
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
