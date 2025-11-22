import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirestoreService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func createUser(uid: String, username: String) async throws {
        try await db.collection("users")
            .document(uid)
            .setData([
                "username": username,
                "createdAt": Date().timeIntervalSince1970
            ])
    }
    
    func updateProfileImage(uid: String, imageUrl: String) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.updateData([
            "profileImageUrl": imageUrl
        ])
    }
    
    func fetchUser(uid: String) async throws -> [String: Any] {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "UserNotFound", code: 404)
        }
        return data
    }
    
    func getUser() async throws -> [User] {
        let snapshot = try await db.collection("users").getDocuments()
        return snapshot.documents.map { doc in
            User(uid: doc.documentID, dict: doc.data())
        }
    }
    
    func createPost(ownerUid: String, ownerName: String, ownerImage: String, imageUrl: String, caption: String?) async throws {
        let doc = db.collection("posts").document()
        var data: [String: Any] = [
            "postId": doc.documentID,
            "ownerUid": ownerUid,
            "ownerName": ownerName,
            "ownerImage": ownerImage,
            "imageUrl": imageUrl,
            "timestamp": Date().timeIntervalSince1970,
            "createdAt": Date(),
            "likeCount": 0
        ]
        if let caption = caption {
            data["caption"] = caption
        }
        try await doc.setData(data)
    }
    
    func fetchFeed(limit: Int = 50) async throws -> [Post] {
        let query = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        return snapshot.documents.map { doc in
            Post(id: doc.documentID, dict: doc.data())
        }
    }
    
    func toggleLike(postId: String, uid: String, isLiked: Bool) async throws {
        let postRef = db.collection("posts").document(postId)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let postDoc = try transaction.getDocument(postRef)
                    let currentLikes = postDoc.data()?["likeCount"] as? Int ?? 0
                    var updatedData: [String: Any] = [:]

                    if isLiked {
                        let likes = postDoc.data()?["likes"] as? [String] ?? []
                        let newLikes = likes.filter { $0 != uid }
                        updatedData["likes"] = newLikes
                        updatedData["likeCount"] = max(currentLikes - 1, 0)
                    } else {
                        let likes = postDoc.data()?["likes"] as? [String] ?? []
                        let newLikes = likes + [uid]
                        updatedData["likes"] = newLikes
                        updatedData["likeCount"] = currentLikes + 1
                    }

                    transaction.updateData(updatedData, forDocument: postRef)
                    return true
                } catch {
                    errorPointer?.pointee = error as NSError
                    return false
                }
            }) { (_, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func addComment(postId: String, uid: String, ownerName: String, text: String) async throws {
        let doc = db.collection("posts").document(postId).collection("comments").document()
        try await doc.setData([
            "commentId": doc.documentID,
            "uid": uid,
            "ownerName": ownerName,
            "text": text,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func fetchComments(postId: String) async throws -> [Comment] {
        let query = db.collection("posts").document(postId)
            .collection("comments")
            .order(by: "timestamp")
        
        let snapshot = try await query.getDocuments()
        return snapshot.documents.map { doc in
            Comment(id: doc.documentID, dict: doc.data())
        }
    }
    
    func fetchLikes(postId: String) async throws -> [String] {
        let doc = try await db.collection("posts").document(postId).getDocument()
        return doc.data()?["likes"] as? [String] ?? []
    }
}
