import Foundation

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}
