import UIKit

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: CreatePostRepository
    
    init(repository: CreatePostRepository = Environment.shared.createPostRepository) {
        self.repository = repository
    }

    func uploadPost(image: UIImage, caption: String) async {
        guard let uid = DefaultManager.shared.get(DefaultManager.uid) else {
            self.errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            try await repository.createPost(ownerUid: uid, image: image, caption: caption)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
