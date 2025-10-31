import SwiftUI

enum SLAState { case ok, warning, critical }

struct SLAHelper {
    static func color(for deadline: Date?) -> Color {
        guard let deadline else { return .primary }
        let remaining = deadline.timeIntervalSinceNow
        switch remaining {
        case ..<0:                 return .red
        case 0..<3600:             return .red
        case 3600..<(4*3600):      return .orange
        default:                   return .green
        }
    }
}
