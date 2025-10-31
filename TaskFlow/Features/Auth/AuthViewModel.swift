import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var role: UserRole = .worker
    @Published var errorMessage: String?

    init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        if let user = Auth.auth().currentUser {
            do {
                try await UserService.shared.ensureUserDocument(uid: user.uid, email: user.email)
                role = try await TaskService.shared.fetchUserRole(uid: user.uid)
                isAuthenticated = true
            } catch {
                print("Oturum geri yüklenemedi: \(error.localizedDescription)")
                isAuthenticated = false
            }
        } else {
            isAuthenticated = false
        }
    }

    func signIn() async {
        do {
            try await AuthService.shared.signIn(email: email, password: password)
            guard let uid = AuthService.shared.currentUserId else { throw NSError(domain: "auth", code: -1) }
            try await UserService.shared.ensureUserDocument(uid: uid, email: email)
            role = try await TaskService.shared.fetchUserRole(uid: uid)
            isAuthenticated = true
        } catch {
            errorMessage = "Geçersiz kimlik bilgisi."
            isAuthenticated = false
        }
    }

    func signOut() {
        do {
            try AuthService.shared.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = "Çıkış yapılamadı."
        }
    }
}
