import Foundation

struct ProfileImage: Codable {
    let profileImage: ImageSizes
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ImageSizes: Codable {
    let small: String

    private enum CodingKeys: String, CodingKey {
        case small = "small"
    }
}
