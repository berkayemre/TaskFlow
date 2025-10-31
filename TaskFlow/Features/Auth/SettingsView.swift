import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("theme") private var theme: Int = 2 
    @State private var notificationsSLA = true
    @State private var notificationsAssign = true
    @State private var notificationsChecklist = false

    var body: some View {
        Form {
            Section("Tema") {
                Picker("Tema", selection: $theme) {
                    Text("Açık").tag(0)
                    Text("Koyu").tag(1)
                    Text("Sistem").tag(2)
                }
            }

            Section("Kullanıcı Bilgileri") {
                Toggle("SLA", isOn: $notificationsSLA)
                Toggle("Checklist", isOn: $notificationsChecklist)
            }

            Section("Veri") {
                Text("Kullanıcı: \(authVM.email)")
                Text("Rol: \(authVM.role == .admin ? "Yetkili" : "Çalışan")")
            }

            Section {
                Button("Çıkış Yap", role: .destructive) { authVM.signOut() }
            }
        }
        .navigationTitle("Ayarlar")
    }
}
