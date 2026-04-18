import SwiftUI

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("PAUSED")
                    .font(.custom("Courier-Bold", size: 28))
                    .foregroundColor(Color(hex: "#00E5FF"))
                    .tracking(6)

                menuButton("RESUME", action: onResume)
                menuButton("RESTART", action: onRestart)
                menuButton("EXIT", action: onExit)
            }
        }
    }

    func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Courier", size: 16))
                .foregroundColor(.white)
                .tracking(3)
                .frame(width: 180, height: 44)
                .overlay(RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "#00E5FF").opacity(0.5), lineWidth: 1))
        }
    }
}
