import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar()
    func updateProfileDetails(profile: Profile?)
}
