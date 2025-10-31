import Foundation
import UIKit

final class PDFService {
    static let shared = PDFService()
    private init() {}

    private var reportsDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("TaskFlowReports", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func fileName(for task: TaskItem) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmm"
        let ts = df.string(from: Date())
        return "TASKFLOW_\(ts)_\(task.id.prefix(6)).pdf"
    }

    @discardableResult
    func generateReport(for task: TaskItem) throws -> URL {
        let meta: [CFString: Any] = [
            kCGPDFContextCreator: "TaskFlow",
            kCGPDFContextAuthor: "TaskFlow"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = meta as [String: Any]
        let page = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: page, format: format)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let pad: CGFloat = 24
            var y: CGFloat = pad

            func draw(_ text: String, font: UIFont = .systemFont(ofSize: 14, weight: .regular)) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font]
                let max = CGSize(width: page.width - 2*pad, height: .greatestFiniteMagnitude)
                let size = (text as NSString).boundingRect(with: max, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: attrs, context: nil).size
                (text as NSString).draw(in: CGRect(x: pad, y: y, width: page.width - 2*pad, height: size.height), withAttributes: attrs)
                y += size.height + 10
            }

            draw("Görev Raporu", font: .systemFont(ofSize: 22, weight: .bold))
            draw("Başlık: \(task.title)")
            draw("Açıklama: \(task.detail)")
            draw("Durum: \(task.status.rawValue)")
            if let loc = task.locationName { draw("Konum: \(loc)") }
            if let sla = task.slaDeadline {
                let df = DateFormatter(); df.dateFormat = "dd.MM.yyyy HH:mm"
                draw("SLA: \(df.string(from: sla))")
            }
            draw("Atanan UID: \(task.assigneeUserId)")
            draw("Oluşturan UID: \(task.createdBy)")
        }

        let destURL = reportsDirectory.appendingPathComponent(fileName(for: task))
        try data.write(to: destURL, options: .atomic)

        NotificationCenter.default.post(name: .reportCreated, object: destURL)

        return destURL
    }
}
