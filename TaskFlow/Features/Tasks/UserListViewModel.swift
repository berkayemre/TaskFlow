import Foundation
import FirebaseFirestore

@MainActor
final class UserListViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var isLoading = false
    @Published var error: String?

    private var listener: ListenerRegistration?

    func startListening() {
        stopListening()
        isLoading = true
        listener = Firestore.firestore()
            .collection("users")
            .order(by: "displayName", descending: false)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                defer { self.isLoading = false }
                if let err {
                    self.error = "Kullanıcılar alınamadı: \(err.localizedDescription)"
                    self.users = []
                    return
                }
                self.error = nil
                self.users = snap?.documents.compactMap { try? $0.data(as: AppUser.self) } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
