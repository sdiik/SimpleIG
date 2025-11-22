import Foundation

protocol HomeRepository {
    func getUsers() async throws -> [User]
    func fetchFeed(limit: Int) async throws -> [Post]
    func like(postId: String, by uid: String, isLiked: Bool) async throws
    func addComment(postId: String, uid: String, text: String) async throws
    func fetchComments(postId: String) async throws -> [Comment]
    func fetchLikes(postId: String) async throws -> [String]
}

final class HomeRepositoryImpl: HomeRepository {
    private let firestore: FirestoreService
    
    init(firestore: FirestoreService) {
        self.firestore = firestore
    }
    
    func getUsers() async throws -> [User] {
        let users =  try await firestore.getUser()
        return users
    }

    func fetchFeed(limit: Int = 50) async throws -> [Post] {
        return try await firestore.fetchFeed(limit: limit)
    }
    
    func like(postId: String, by uid: String, isLiked: Bool) async throws {
        try await firestore.toggleLike(postId: postId, uid: uid, isLiked: isLiked)
    }
    
    func addComment(postId: String, uid: String, text: String) async throws {
        let user = CoreDataManager.shared.fetchUser()
        let ownerName = user?.username ?? "Anonymous"
        try await firestore.addComment(postId: postId, uid: uid, ownerName: ownerName, text: text)
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        try await firestore.fetchComments(postId: postId)
    }
    
    func fetchLikes(postId: String) async throws -> [String] {
        try await firestore.fetchLikes(postId: postId)
    }
}
