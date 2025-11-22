import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import UIKit

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func signup(email: String, username: String, password: String) async throws -> User
    func logout() async throws
    func loginGoogle(presentingVC: UIViewController) async throws -> User
}

final class AuthRepositoryImpl: AuthRepository {

    private let authService: FirebaseAuthService
    private let firestoreService: FirestoreService

    init(authService: FirebaseAuthService, firestoreService: FirestoreService) {
        self.authService = authService
        self.firestoreService = firestoreService
    }

    func login(email: String, password: String) async throws -> User {
        try authService.signOut()
        
        let uid = try await authService.signIn(email: email, password: password)
        DefaultManager.shared.set(uid, for: DefaultManager.uid)
        
        let userData = try await firestoreService.fetchUser(uid: uid)
        saveUserToCoreData(uid: uid, dict: userData)
        
        return User(uid: uid, dict: userData)
    }

    func signup(email: String, username: String, password: String) async throws -> User {
        try authService.signOut()
        
        let uid = try await authService.signUp(email: email, password: password)
        try await firestoreService.createUser(uid: uid, username: username)
        
        let userData = try await firestoreService.fetchUser(uid: uid)
        saveUserToCoreData(uid: uid, dict: userData)
        
        return User(uid: uid, dict: userData)
    }

    func logout() async throws {
        try authService.signOut()
    }

    func loginGoogle(presentingVC: UIViewController) async throws -> User {
        let gidUser = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
        
        guard let idToken = gidUser.user.idToken else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Google tokens not found"])
        }
        
        let accessToken = gidUser.user.accessToken
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken.tokenString,
            accessToken: accessToken.tokenString
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        let username = gidUser.user.profile?.name ?? "Google User"
        
        try await firestoreService.createUser(uid: authResult.user.uid, username: username)
        
        let userData: [String: Any] = ["username": username]
        saveUserToCoreData(uid: authResult.user.uid, dict: userData)
        
        return User(uid: authResult.user.uid, dict: userData)
    }

    private func saveUserToCoreData(uid: String, dict: [String: Any]) {
        let context = CoreDataManager.shared.context
        let user = UserSaved(context: context)
        
        user.uid = uid
        user.username = dict["username"] as? String ?? ""
        user.fullname = dict["fullname"] as? String ?? ""
        user.profileImageUrl = dict["profileImageUrl"] as? String ?? ""
        user.bio = dict["bio"] as? String ?? ""
        user.createdAt = dict["createdAt"] as? Date ?? Date()
        
        CoreDataManager.shared.saveContext()
    }
}
