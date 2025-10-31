import Foundation

struct TaskItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var detail: String
    var assigneeUserId: String
    var status: TaskStatus
    var createdAt: Date
    var slaDeadline: Date?
    var locationName: String?
    var createdBy: String
}
