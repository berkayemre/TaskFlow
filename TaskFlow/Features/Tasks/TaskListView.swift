import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = TaskListViewModel()
    @State private var showingNew = false

    var body: some View {
        VStack {
            if authVM.role == .admin {
                Button("Yeni Görev Oluştur") {
                    showingNew = true
                }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingNew) {
                        NewTaskView()
                            .environmentObject(authVM)
                    }
            }

            List(vm.tasks) { task in
                NavigationLink {
                    TaskDetailView(task: task)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(task.title)
                                .font(.headline)
                        }
                        Text(task.status.rawValue).font(.subheadline)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if task.status.next() != nil {
                        Button("İlerle") {
                            Task {
                                await vm.advance(task)
                            }
                        }
                        .tint(.blue)
                    }
                }
            }

            if let e = vm.error {
                Text(e).foregroundColor(.red).padding(.bottom, 8)
            }
        }
        .navigationTitle("Görevler")
        .task { vm.startListening() }
        .onDisappear { vm.stopListening() }
    }
}
