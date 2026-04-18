import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    private let audio = AudioService.shared

    @Published var bgmEnabled: Bool {
        didSet { audio.bgmEnabled = bgmEnabled }
    }

    @Published var seEnabled: Bool {
        didSet { audio.seEnabled = seEnabled }
    }

    init() {
        self.bgmEnabled = AudioService.shared.bgmEnabled
        self.seEnabled = AudioService.shared.seEnabled
    }
}
