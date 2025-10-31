import Foundation
import FirebaseFirestore

final class TaskService {
    static let shared = TaskService()
    private init() {}
    private let db = Firestore.firestore()

    private var tasksRef: CollectionReference { db.collection("tasks") }
    private var usersRef: CollectionReference { db.collection("users") }

    func fetchUserRole(uid: String) async throws -> UserRole {
        let snap = try await usersRef.document(uid).getDocument()
        let roleRaw = (snap.data()?["role"] as? String) ?? "worker"
        return UserRole(rawValue: roleRaw) ?? .worker
    }

    func createTask(_ task: TaskItem) async throws {
        var data = try Firestore.Encoder().encode(task)
        data["createdAt"] = Timestamp(date: task.createdAt)
        if let sla = task.slaDeadline { data["slaDeadline"] = Timestamp(date: sla) }
        try await tasksRef.document(task.id).setData(data)
    }

    func advanceStatus(task: TaskItem) async throws {
        guard let next = task.status.next() else { return }
        try await tasksRef.document(task.id).updateData(["status": next.rawValue])
    }
}

