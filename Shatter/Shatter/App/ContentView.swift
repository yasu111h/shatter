import SwiftUI

struct ContentView: View {
    @State private var showLevelSelect = false
    @State private var showSettings = false

    var body: some View {
        TitleView(
            showLevelSelect: $showLevelSelect,
            showSettings: $showSettings
        )
        .preferredColorScheme(.dark)
    }
}

// #Preview {
//     ContentView()
// }
