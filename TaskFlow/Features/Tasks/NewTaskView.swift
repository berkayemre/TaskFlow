import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = NewTaskViewModel()
    @StateObject private var userVM = UserListViewModel()

    @State private var selectedUserId: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("ZORUNLU ALANLAR") {
                    TextField("Başlık", text: $vm.title)

                    if userVM.isLoading {
                        HStack { ProgressView(); Text("Kullanıcılar yükleniyor...") }
                    } else if let err = userVM.error {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kullanıcı listesi yüklenemedi.")
                                .foregroundStyle(.red)
                            Text(err).font(.caption).foregroundStyle(.secondary)
                            Button("Tekrar Dene") { userVM.startListening() }
                        }
                    } else if userVM.users.isEmpty {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                            Text("Hiç kullanıcı bulunamadı")
                            Spacer()
                            Button("Yenile") { userVM.startListening() }
                        }
                    } else {
                        Picker("Atanacak Kişi", selection: $selectedUserId) {
                            Text("Seçiniz").tag("")
                            ForEach(userVM.users) { user in
                                Text(user.displayName).tag(user.id ?? "")
                            }
                        }
                    }
                }

                Section("DETAY") {
                    TextField("Açıklama", text: $vm.detail, axis: .vertical)
                    Stepper("SLA (saat): \(vm.slaHours)", value: $vm.slaHours, in: 1...168)
                }

                if let err = vm.error {
                    Text(err).foregroundColor(.red)
                }
            }
            .navigationTitle("Yeni Görev")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        Task {
                            guard let uid = AuthService.shared.currentUserId else { return }
                            if await vm.save(currentUserId: uid, assigneeId: selectedUserId) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.canSave(userRole: authVM.role, assigneeId: selectedUserId))
                }
            }
        }
        .onAppear { userVM.startListening() }
        .onDisappear { userVM.stopListening() }
    }
}
