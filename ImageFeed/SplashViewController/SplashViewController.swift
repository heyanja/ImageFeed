import UIKit
import ProgressHUD
import SnapKit

final class SplashViewController: UIViewController {
    
    static let didChangeNotification = Notification.Name("ProfileInfoDidRecieve")
    
    private var isFirst = true
    private var username: String?
    private let imageListViewController = ImagesListViewController()
    private let oAuthService = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var logoImage: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "launch_icon")
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst {
            if let token = OAuth2TokenStorage().token {
                fetchProfile(token: token)
                fetchImageProfile(token: token)
                switchToTabBarController()
            } else {
                switchToAuthController()
                isFirst = false
            }
        } else {
            switchToTabBarController()
        }
    }
    
    private func switchToAuthController() {
        let authViewController = AuthViewController()
        authViewController.modalPresentationStyle = .fullScreen
        authViewController.delegate = self
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
    
    private func fetchOAuthToken(code: String) {
        oAuthService.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
                print("Ошибка получения bearer token \(error)")
            }
        }
    }
    
    private func fetchProfile(token: String) {
        self.profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.username = profile.username
                UIBlockingProgressHUD.dismiss()
                self.fetchImageProfile(token: token)
                self.switchToTabBarController()
                NotificationCenter.default.post(
                    name: SplashViewController.didChangeNotification,
                    object: self,
                    userInfo: ["ProfileInfo": profile])
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
                print(error)
            }
        }
    }
    
    private func fetchImageProfile(token: String) {
        if let username = username {
            profileImageService.fetchProfileImageURL(token: token, username: username) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case.success(let avatarURL):
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                case.failure(let error):
                    self.showAlert()
                    print(error)
                }
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func setupSplashView() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code: code)
        }
        UIBlockingProgressHUD.show()
    }
}
