import UIKit
import Kingfisher
@testable import ImageFeed

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    let avatarImage = UIImageView()
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {}
    
    func setImage(stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        avatarImage.kf.setImage(with: url)
    }
}
