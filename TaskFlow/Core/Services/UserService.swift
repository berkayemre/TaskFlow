import Foundation
import FirebaseAuth
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private init() {}
    private let db = Firestore.firestore()

    private var usersRef: CollectionReference { db.collection("users") }

    func ensureUserDocument(uid: String, email: String?) async throws {
        let doc = usersRef.document(uid)
        let snap = try await doc.getDocument()
        if snap.exists { return }

        let nameFromEmail: String = {
            guard let e = email, let prefix = e.split(separator: "@").first else { return "Kullanıcı" }
            return prefix.replacingOccurrences(of: ".", with: " ").capitalized
        }()

        try await doc.setData([
            "displayName": nameFromEmail,
            "role": "worker",
            "email": email ?? ""
        ])
    }
}
