import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Anasayfa", systemImage: "house.fill") }

            NavigationStack { TaskListView() }
                .tabItem { Label("Görevler", systemImage: "checklist") }

            NavigationStack { ReportsView() }
                .tabItem { Label("Raporlar", systemImage: "doc.richtext") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
        }
    }
}
