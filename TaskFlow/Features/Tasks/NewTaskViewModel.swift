import Foundation

@MainActor
final class NewTaskViewModel: ObservableObject {
    @Published var title = ""
    @Published var detail = ""
    @Published var slaHours: Int = 24
    @Published var error: String?

    func canSave(userRole: UserRole, assigneeId: String) -> Bool {
        guard userRole == .admin else { return false }
        return !title.trimmingCharacters(in: .whitespaces).isEmpty &&
               !assigneeId.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save(currentUserId: String, assigneeId: String) async -> Bool {
        guard canSave(userRole: .admin, assigneeId: assigneeId) else {
            self.error = "Zorunlu alanlar eksik veya yetkisiz!"
            return false
        }
        let deadline = Calendar.current.date(byAdding: .hour, value: slaHours, to: Date())
        let item = TaskItem(
            title: title,
            detail: detail,
            assigneeUserId: assigneeId,
            status: .planned,
            createdAt: Date(),
            slaDeadline: deadline,
            locationName: nil,
            createdBy: currentUserId
        )
        do {
            try await TaskService.shared.createTask(item)
            return true
        } catch {
            self.error = "Kayıt başarısız: \(error.localizedDescription)"
            return false
        }
    }
}
