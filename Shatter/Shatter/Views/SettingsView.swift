import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#00E5FF"))
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                    Text("SETTINGS")
                        .font(.custom("Courier-Bold", size: 20))
                        .foregroundColor(Color(hex: "#00E5FF"))
                        .tracking(4)
                    Spacer()
                    Color.clear.frame(width: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)

                // 設定項目
                VStack(spacing: 0) {
                    SettingsRow(
                        title: "BGM",
                        subtitle: "バックグラウンドミュージック",
                        icon: "music.note",
                        isEnabled: $viewModel.bgmEnabled
                    )

                    Divider()
                        .background(Color(hex: "#00E5FF").opacity(0.15))

                    SettingsRow(
                        title: "SOUND EFFECTS",
                        subtitle: "効果音",
                        icon: "speaker.wave.2",
                        isEnabled: $viewModel.seEnabled
                    )
                }
                .background(Color(hex: "#111111"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#00E5FF").opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()

                // バージョン情報
                Text("SHATTER v1.0")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(Color.gray.opacity(0.4))
                    .tracking(2)
                    .padding(.bottom, 32)
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#00E5FF"))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Courier-Bold", size: 15))
                    .foregroundColor(.white)
                    .tracking(2)
                Text(subtitle)
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(Color.gray.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .toggleStyle(CyanToggleStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

// カスタムトグルスタイル
struct CyanToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color(hex: "#00E5FF") : Color(hex: "#333333"))
                .frame(width: 52, height: 30)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                        .offset(x: configuration.isOn ? 11 : -11)
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isOn)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
