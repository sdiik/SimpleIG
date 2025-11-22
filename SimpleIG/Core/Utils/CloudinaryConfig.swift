import Foundation

struct CloudinaryConfig {
    static let cloudName: String = "ddn7gpfpa"
    static let uploadPreset: String = "unsigned_profile"

    static var uploadURL: URL {
        return URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
    }
}
