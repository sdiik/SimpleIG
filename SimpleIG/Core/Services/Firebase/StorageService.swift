import Foundation
import UIKit
import FirebaseStorage

final class StorageService {
    func uploadProfilePhoto(uid: String, image: UIImage) async throws -> String {
        let url = try await CloudinaryService().uploadImage(image)
        try await FirestoreService().updateProfileImage(uid: uid, imageUrl: url)
        return url
    }
}
