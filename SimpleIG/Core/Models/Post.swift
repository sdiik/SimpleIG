import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let ownerUid: String
    let ownerName: String?
    let ownerImage: String?
    let imageUrl: String
    let caption: String?
    let timestamp: Date
    var likeCount: Int
    var likes: [String]

    init(id: String, dict: [String: Any]) {
        self.id = id
        self.ownerUid = dict["ownerUid"] as? String ?? ""
        self.ownerName = dict["ownerName"] as? String ?? ""
        self.ownerImage = dict["ownerImage"] as? String ?? ""
        self.imageUrl = dict["imageUrl"] as? String ?? ""
        self.caption = dict["caption"] as? String
        self.timestamp = dict["createdAt"] as? Date ?? Date()
        self.likeCount = dict["likeCount"] as? Int ?? 0
        self.likes = dict["likes"] as? [String] ?? []
    }
}
