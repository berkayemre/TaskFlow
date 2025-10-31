import Foundation

struct ReportItem: Identifiable {
    let id = UUID().uuidString
    let fileName: String
    let summary: String
    let url: URL
}

