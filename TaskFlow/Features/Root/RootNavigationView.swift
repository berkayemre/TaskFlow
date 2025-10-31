import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            HomeView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Ayarlar") { SettingsView() }
                    }
                }
        }
        .environmentObject(authVM)
    }
}
