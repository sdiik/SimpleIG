import Foundation

struct Comment: Codable, Identifiable {
    let id: String
    let ownerName: String
    let uid: String
    let text: String
    let timestamp: Date
    
    init(id: String, dict: [String: Any]) {
        self.id = id
        self.uid = dict["uid"] as? String ?? ""
        self.ownerName = dict["ownerName"] as? String ?? ""
        self.text = dict["text"] as? String ?? ""
        if let ts = dict["timestamp"] as? TimeInterval { self.timestamp = Date(timeIntervalSince1970: ts) } else { self.timestamp = Date() }
    }
}
