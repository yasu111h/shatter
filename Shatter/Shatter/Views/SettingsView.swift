import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsViewModel
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0A").ignoresSafeArea()
            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "#00E5FF"))
                            .font(.system(size: 18))
                    }
                    Spacer()
                    Text("SETTINGS")
                        .font(.custom("Courier-Bold", size: 16))
                        .foregroundColor(.white)
                        .tracking(4)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider().background(Color(hex: "#00E5FF").opacity(0.2))

                List {
                    Section {
                        settingsRow("BGM", isOn: $settings.isBGMEnabled)
                        settingsRow("SOUND EFFECTS", isOn: $settings.isSEEnabled)
                    } header: {
                        Text("SOUND")
                            .font(.custom("Courier", size: 12))
                            .foregroundColor(Color(hex: "#00E5FF"))
                            .tracking(3)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                Spacer()
            }
        }
    }

    func settingsRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.custom("Courier", size: 14))
                .foregroundColor(.white)
                .tracking(2)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color(hex: "#00E5FF"))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }
}
