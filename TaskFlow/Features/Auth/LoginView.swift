import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("TaskFlow")
                .font(.largeTitle).bold()
            TextField("E-posta", text: $authVM.email)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            SecureField("Şifre", text: $authVM.password)
                .textFieldStyle(.roundedBorder)
            if let e = authVM.errorMessage { Text(e).foregroundStyle(.red) }
            Button("Giriş Yap") {
                Task { await authVM.signIn() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
