import SwiftUI
import QuickLook

private struct PreviewDocument: Identifiable {
    let id = UUID()
    let url: URL
}

struct ReportsView: View {
    @StateObject private var vm = ReportsViewModel()
    @State private var previewDoc: PreviewDocument?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            if vm.items.isEmpty {
                VStack(spacing: 8) {
                    Text("Henüz rapor yok")
                        .foregroundStyle(.secondary)
                    Button("Yenile") { vm.scanReports() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.fileName).font(.headline)
                        Text(item.summary).font(.subheadline).foregroundStyle(.secondary)
                        HStack {
                            Button("PDF Aç") { previewDoc = PreviewDocument(url: item.url) }
                            Spacer()
                            ShareLink("Paylaş", item: item.url)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding([.horizontal, .top])
        .onAppear { vm.scanReports() }
        .onReceive(NotificationCenter.default.publisher(for: .reportCreated)) { _ in
            vm.scanReports()
        }
        .sheet(item: $previewDoc, onDismiss: { previewDoc = nil }) { doc in
            NavigationStack {
                QLPreviewControllerRepresentable(url: doc.url)
                    .ignoresSafeArea()
                    .navigationTitle(doc.url.lastPathComponent)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Kapat") { previewDoc = nil }
                        }
                    }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
            .interactiveDismissDisabled(false)
        }
        .navigationTitle("Raporlar")
    }
}

private struct QLPreviewControllerRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let c = QLPreviewController()
        c.dataSource = context.coordinator
        return c
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
