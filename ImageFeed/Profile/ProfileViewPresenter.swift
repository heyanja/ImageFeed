import UIKit

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    static let didChangeProfileNotification = Notification.Name("ProfileInfoDidRecieve")
    static let didChangeProfileImageNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileInfoServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    
    func profileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileViewPresenter.didChangeProfileImageNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    func profileInfoObserver() {
        profileInfoServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileViewPresenter.didChangeProfileNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateProfileDetails(profile: profileService.profile)
            }
        self.view?.updateProfileDetails(profile: profileService.profile)
    }
    
    func showLogoutAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Пока-пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да",
                                      style: .default) { _ in
            OAuth2TokenStorage().deleteToken()
            WebViewViewController.cleanCookies()
            let splashVC = SplashViewController()
            splashVC.isFirst = true
            splashVC.modalPresentationStyle = .fullScreen
            vc.present(splashVC, animated: true)
        }
        let noAction = UIAlertAction(title: "Нет",
                                     style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        vc.present(alert, animated: true)
    }
}
