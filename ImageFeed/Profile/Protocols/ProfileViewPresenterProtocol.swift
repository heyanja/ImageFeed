import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func showLogoutAlert(vc: UIViewController)
    func profileImageObserver()
    func profileInfoObserver()
}
