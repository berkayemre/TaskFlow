import Foundation
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {
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
                if let err {
                    self.error = "Özet verileri alınamadı: \(err.localizedDescription)"
                    return
                }
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

    var pendingCount: Int {
        tasks.filter { $0.status == .planned || $0.status == .todo }.count
    }

    var activeCount: Int {
        tasks.filter { $0.status == .inProgress || $0.status == .review }.count
    }

    var doneCount: Int {
        tasks.filter { $0.status == .done }.count
    }

    var workTimeToday: (hours: Int, minutes: Int) {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())

        let activeToday = tasks.filter {
            ($0.status == .inProgress || $0.status == .review) &&
            $0.createdAt >= startOfDay
        }

        let totalSec = activeToday.reduce(0.0) { acc, t in
            acc + Date().timeIntervalSince(t.createdAt)
        }

        let minutes = Int(totalSec / 60)
        return (minutes / 60, minutes % 60)
    }
}
