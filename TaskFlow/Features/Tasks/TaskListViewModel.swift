import Foundation
import FirebaseFirestore

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var error: String?
    private var listener: ListenerRegistration?

    func startListening() {
        stopListening()
        listener = Firestore.firestore()
            .collection("tasks")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { self.error = "Dinleme hatası: \(err.localizedDescription)"; return }
                self.tasks = snap?.documents.compactMap { doc in
                    var item = try? doc.data(as: TaskItem.self)
                    if item?.id != doc.documentID { item?.id = doc.documentID }
                    return item
                } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func advance(_ task: TaskItem) async {
        do { try await TaskService.shared.advanceStatus(task: task) }
        catch { self.error = "Durum güncellenemedi: \(error.localizedDescription)" }
    }
}
