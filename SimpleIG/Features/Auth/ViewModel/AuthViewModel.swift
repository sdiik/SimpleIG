import Foundation
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let repo: AuthRepository

    init(repo: AuthRepository = Environment.shared.authRepository) {
        self.repo = repo
    }

    func login() async {
        isLoading = true
        errorMessage = ""
        
        defer { isLoading = false }

        do {
            
            _ = try await repo.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await repo.signup(email: email, username: username, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loginGoogle(presentingVC: UIViewController) async {
          do {
              isLoading = true
              errorMessage = ""
              let _ = try await repo.loginGoogle(presentingVC: presentingVC)
              print("Google login berhasil")
          } catch {
              errorMessage = error.localizedDescription
          }
          isLoading = false
      }
}
