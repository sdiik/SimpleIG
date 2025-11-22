import Foundation
import UIKit

protocol CreatePostRepository {
    func createPost(ownerUid: String, image: UIImage, caption: String?) async throws
}

final class CreatePostRepositoryImpl: CreatePostRepository {
    private let storage: StorageService
    private let firestore: FirestoreService

    init(storage: StorageService, firestore: FirestoreService) {
        self.storage = storage
        self.firestore = firestore
    }
    
    func createPost(ownerUid: String, image: UIImage, caption: String?) async throws {
        let user = CoreDataManager.shared.fetchUser()
        let ownerName = user?.username ?? "Anonymous"
        let ownerImage = user?.profileImageUrl ?? ""
        
        let url = try await CloudinaryService().uploadImage(image)
        try await firestore.createPost(ownerUid: ownerUid, ownerName: ownerName, ownerImage: ownerImage, imageUrl: url, caption: caption)
    }
}
