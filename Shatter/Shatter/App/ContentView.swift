import SwiftUI

enum AppScreen {
    case title
    case levelSelect
    case game(levelId: Int)
    case settings
}

struct ContentView: View {
    @State private var screen: AppScreen = .title
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some View {
        ZStack {
            switch screen {
            case .title:
                TitleView(
                    onStart: { screen = .levelSelect },
                    onSettings: { screen = .settings }
                )
                .transition(.opacity)

            case .levelSelect:
                LevelSelectView(
                    onSelect: { levelId in screen = .game(levelId: levelId) },
                    onBack: { screen = .title }
                )
                .transition(.opacity)

            case .game(let levelId):
                GameView(
                    levelId: levelId,
                    onExit: { screen = .levelSelect }
                )
                .transition(.opacity)

            case .settings:
                SettingsView(
                    settings: settingsVM,
                    onClose: { screen = .title }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: screenKey)
    }

    private var screenKey: String {
        switch screen {
        case .title: return "title"
        case .levelSelect: return "levelSelect"
        case .game(let id): return "game_\(id)"
        case .settings: return "settings"
        }
    }
}
