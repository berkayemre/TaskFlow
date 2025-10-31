import SwiftUI

struct TaskDetailView: View {
    @State var task: TaskItem
    @State private var shareURL: URL?
    @State private var isUpdating = false
    @State private var updateError: String?

    private var nextStatus: TaskStatus? {
        task.status.next()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Görev Detayı")
                    .font(.largeTitle)
                    .bold()
                FlowPillsView(current: task.status)

                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title).font(.title2).bold()
                    Text(task.detail)
                    HStack { Text("Durum:").fontWeight(.semibold); Text(task.status.rawValue) }
                    if let deadline = task.slaDeadline {
                        HStack {
                            Text("SLA:").fontWeight(.semibold)
                            Text(deadline.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(SLAHelper.color(for: deadline))
                        }
                    }
                }
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(12)

                if let next = nextStatus {
                    Button {
                        Task { await advanceStatus() }
                    } label: {
                        HStack {
                            if isUpdating { ProgressView().tint(.white) }
                            Text("\"\(task.status.rawValue)\" → \"\(next.rawValue)\" durumuna ilerlet")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isUpdating)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Görev tamamlandı").fontWeight(.semibold)
                    }
                    .foregroundStyle(.green)

                    Button("PDF Raporu Oluştur") {
                        do {
                            let url = try PDFService.shared.generateReport(for: task)
                            shareURL = url
                        } catch {
                            updateError = "PDF oluşturulamadı: \(error.localizedDescription)"
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if let url = shareURL {
                        ShareLink(item: url,
                                  preview: .init("Görev Raporu", image: Image(systemName: "doc.richtext")))
                    }
                }

                if let err = updateError {
                    Text(err).foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Görev Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func advanceStatus() async {
        guard let next = task.status.next() else { return }
        isUpdating = true
        updateError = nil
        defer { isUpdating = false }

        do {
            try await TaskService.shared.advanceStatus(task: task)
            task.status = next
        } catch {
            updateError = "Durum güncellenemedi: \(error.localizedDescription)"
        }
    }
}

private struct FlowPillsView: View {
    let current: TaskStatus
    var body: some View {
        let all = TaskStatus.allCases
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(all, id: \.self) { status in
                    Text(status.rawValue)
                        .font(.caption).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(color(for: status).opacity(status == current ? 0.9 : 0.25))
                        )
                        .overlay(
                            Capsule().stroke(color(for: status), lineWidth: status == current ? 0 : 1)
                        )
                        .foregroundStyle(status == current ? .white : color(for: status))
                }
            }
        }
    }
    private func color(for s: TaskStatus) -> Color {
        switch s {
        case .planned: return .gray
        case .todo: return .blue
        case .inProgress: return .purple
        case .review: return .orange
        case .done: return .green
        }
    }
}

