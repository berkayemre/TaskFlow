import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = HomeViewModel()
    @State private var showingNew = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Anasayfa")
                        .font(.largeTitle).bold()

                    Text("İş Özeti").font(.headline)

                    HStack(spacing: 12) {
                        StatCard(title: "Bekleyen", value: "\(vm.pendingCount)")
                        StatCard(title: "Aktif", value: "\(vm.activeCount)")
                        StatCard(title: "Tamamlanan", value: "\(vm.doneCount)")
                    }

                    let wt = vm.workTimeToday
                    StatWideCard(title: "Çalışma süresi",
                                 value: "\(wt.hours)s \(wt.minutes)dk")

                    Text("Kısayollar").font(.headline)

                    VStack(spacing: 12) {
                        NavigationLink {
                            TaskListView()
                        } label: {
                            NavCardLabel(title: "Görevlerim", systemImage: "checklist")
                        }

                        NavigationLink {
                            ReportsView()
                        } label: {
                            NavCardLabel(title: "Raporlarım", systemImage: "doc.richtext")
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            NavCardLabel(title: "Ayarlar", systemImage: "gear")
                        }
                    }

                    if authVM.role == .admin {
                        Button {
                            showingNew = true
                        } label: {
                            Text("Yeni Görev Oluştur")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        .sheet(isPresented: $showingNew) {
                            NewTaskView()
                                .environmentObject(authVM)
                        }
                    }

                    if let err = vm.error {
                        Text(err)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

private struct StatWideCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline)
            Text(value).font(.title3).bold()
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

private struct NavCardLabel: View {
    let title: String
    let systemImage: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .imageScale(.large)
            Text(title).font(.headline)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(.gray.opacity(0.2))
        .cornerRadius(12)
    }
}
