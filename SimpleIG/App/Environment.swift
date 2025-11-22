import Foundation

final class Environment {
    static let shared = Environment()

    let authService: FirebaseAuthService
    let firestoreService: FirestoreService
    let storageService: StorageService

    let authRepository: AuthRepository
    let homeRepository: HomeRepository
    let createPostRepository: CreatePostRepository
    let profilePhotoRepository: ProfilePhotoRepository

    private init() {
        self.authService = FirebaseAuthService()
        self.firestoreService = FirestoreService()
        self.storageService = StorageService()

        self.authRepository = AuthRepositoryImpl(
            authService: authService,
            firestoreService: firestoreService
        )

        self.homeRepository = HomeRepositoryImpl(
            firestore: firestoreService
        )

        self.createPostRepository = CreatePostRepositoryImpl(
            storage: storageService,
            firestore: firestoreService
        )

        self.profilePhotoRepository = ProfilePhotoRepositoryImpl(
            firestore: firestoreService,
            storage: storageService
        )
    }
}
