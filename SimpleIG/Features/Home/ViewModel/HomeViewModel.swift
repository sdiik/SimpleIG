import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var users: [User] = []

    @Published var isLoadingFeed: Bool = false
    @Published var isLoadingUsers: Bool = false

    @Published var feedError: String = ""
    @Published var usersError: String = ""

    private let repository: HomeRepository

    init(repository: HomeRepository = Environment.shared.homeRepository) {
        self.repository = repository
    }

    func loadFeed() async {
        isLoadingFeed = true
        feedError = ""

        do {
            posts = try await repository.fetchFeed(limit: 50)
            
            print(posts)
        } catch {
            feedError = error.localizedDescription
        }

        isLoadingFeed = false
    }
    
    func fetchComment(postId: String) async -> [Comment] {
        do {
            let comments = try await repository.fetchComments(postId: postId)
            return comments
        } catch {
            return []
        }
    }
    
    func fetchLikes(postId: String) async {
        do {
            let likes = try await repository.fetchLikes(postId: postId)
            guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
            posts[index].likes = likes
            posts[index].likeCount = likes.count
        } catch {
            print(error)
        }
    }
    
    func loadUsers() async {
        isLoadingUsers = true
        usersError = ""

        do {
            users = try await repository.getUsers()
        } catch {
            usersError = error.localizedDescription
        }

        isLoadingUsers = false
    }
    
    func loadInitialData() async {
        async let feedTask = loadFeed()
        async let userTask = loadUsers()

        _ = await (feedTask, userTask)
    }
    
    func likePost(postId: String, isLiked: Bool) async {
        guard let uid = DefaultManager.shared.get(DefaultManager.uid) else { return }
        do {
            try await repository.like(postId: postId, by: uid, isLiked: isLiked)
        } catch {
            print(error)
        }
    }
    
    func shareItems(for post: Post, completion: @escaping ([Any]) -> Void) {
        var items: [Any] = []
        
        if let caption = post.caption {
            items.append(caption)
        }
        
        if let url = URL(string: post.imageUrl) {
            items.append(url)
        }
        
        completion(items)
    }
    
    func comment(postId: String, comment: String) async {
        guard let uid = DefaultManager.shared.get(DefaultManager.uid) else { return }
        do {
            try await repository.addComment(postId: postId, uid: uid, text: comment)
        } catch {
            print(error)
        }
    }
}
