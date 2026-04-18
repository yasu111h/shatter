import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isBGMEnabled: Bool {
        didSet { UserDefaults.standard.set(isBGMEnabled, forKey: "bgm_enabled") }
    }
    @Published var isSEEnabled: Bool {
        didSet { UserDefaults.standard.set(isSEEnabled, forKey: "se_enabled") }
    }

    init() {
        self.isBGMEnabled = UserDefaults.standard.object(forKey: "bgm_enabled") as? Bool ?? true
        self.isSEEnabled = UserDefaults.standard.object(forKey: "se_enabled") as? Bool ?? true
    }
}
