
import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case planned = "Planlandı"
    case todo = "Yapılacak"
    case inProgress = "Çalışmada"
    case review = "Kontrol"
    case done = "Tamamlandı"

    func next() -> TaskStatus? {
        switch self {
        case .planned:    return .todo
        case .todo:       return .inProgress
        case .inProgress: return .review
        case .review:     return .done
        case .done:       return nil
        }
    }
}
