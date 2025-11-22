import Foundation
import UIKit

@MainActor
final class ProfilePhotoViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""

    @Published var username = ""
    @Published var fullname = ""
    @Published var bio = ""
    @Published var createdAt: String?
    @Published var profileImageUrl: String?

    private let repository: ProfilePhotoRepository
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    init(repository: ProfilePhotoRepository = Environment.shared.profilePhotoRepository) {
        self.repository = repository
        loadUser()
    }

    func loadUser() {
        guard let user = CoreDataManager.shared.fetchUser() else { return }

        username = user.username ?? ""
        fullname = user.fullname ?? ""
        bio = user.bio ?? ""
        createdAt = user.createdAt.flatMap { dateFormatter.string(from: $0) }
        profileImageUrl = user.profileImageUrl
    }

    func uploadProfilePhoto(image: UIImage) async {
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            guard let uid = DefaultManager.shared.get(DefaultManager.uid) else {
                errorMessage = "User ID not found"
                return
            }

            let url = try await repository.updateProfileImage(uid: uid, image: image)

            if let user = CoreDataManager.shared.fetchUser() {
                user.profileImageUrl = url
                CoreDataManager.shared.saveContext()
            }

            profileImageUrl = url
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
