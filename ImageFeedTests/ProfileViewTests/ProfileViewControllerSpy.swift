import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    let profileView = ProfileView()
    let imagesService = ProfileImageServiceStub()
    let profileImage = "https://kafel.ee/wp-content/uploads/2019/02/013-duck.png"
    
    func updateAvatar() {
        imagesService.setImage(stringURL: profileImage)
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {}
    
}
