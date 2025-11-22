import UIKit
import FirebaseStorage

protocol ProfilePhotoRepository {
    func updateProfileImage(uid: String, image: UIImage) async throws -> String
}

final class ProfilePhotoRepositoryImpl: ProfilePhotoRepository {
    private let firestore: FirestoreService
    private let storage: StorageService
    
    init(firestore: FirestoreService, storage: StorageService) {
        self.firestore = firestore
        self.storage = storage
    }
    
    func updateProfileImage(uid: String, image: UIImage) async throws -> String {
        let url = try await storage.uploadProfilePhoto(uid: uid, image: image)
        try await firestore.updateProfileImage(uid: uid, imageUrl: url)
        return url
    }
}
