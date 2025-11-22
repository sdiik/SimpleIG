import Foundation

struct User: Codable {
    let uid: String
    var username: String
    var fullname: String?
    var profileImageUrl: String?
    var bio: String?
    var createdAt: Date?
    
    init(uid: String, dict: [String: Any]) {
        self.uid = uid
        self.username = dict["username"] as? String ?? ""
        self.fullname = dict["fullname"] as? String
        self.profileImageUrl = dict["profileImageUrl"] as? String
        self.bio = dict["bio"] as? String
        if let ts = dict["createdAt"] as? TimeInterval { self.createdAt = Date(timeIntervalSince1970: ts) }
    }
}
