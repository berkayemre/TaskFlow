import Foundation

@MainActor
final class ReportsViewModel: ObservableObject {
    @Published var items: [ReportItem] = []

    func scanReports() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("TaskFlowReports", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            items = []
            return
        }
        let urls = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        let pdfs = urls.filter { $0.pathExtension.lowercased() == "pdf" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }

        self.items = pdfs.map { url in
            ReportItem(fileName: url.lastPathComponent,
                       summary: "PDF",
                       url: url)
        }
    }
}
