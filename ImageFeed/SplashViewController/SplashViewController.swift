import UIKit
import ProgressHUD
import SnapKit

final class SplashViewController: UIViewController {
    
    static let didChangeNotification = Notification.Name("ProfileInfoDidRecieve")
    
    var isFirst = true
    private var username: String?
    private let imageListViewController = ImagesListViewController()
    private let oAuthService = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    private var photosObserver: NSObjectProtocol?
    
    private lazy var logoImage: UIImageView = {
        let element = UIImageView()
        element.image = Resources.Images.launch
        return element
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSplashView()
        if isFirst {
            if let token = OAuth2TokenStorage().token {
                fetchProfile(token: token)
            } else {
                switchToAuthController()
                isFirst = false
            }
        }
    }
    
    private func switchToAuthController() {
        let authViewController = AuthViewController()
        authViewController.modalPresentationStyle = .fullScreen
        authViewController.delegate = self
        present(authViewController, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    private func fetchOAuthToken(code: String) {
        oAuthService.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
                print("Ошибка получения bearer token \(error)")
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.username = profile.username
                self.fetchImageProfile(token: token)
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
                NotificationCenter.default.post(
                    name: SplashViewController.didChangeNotification,
                    object: self,
                    userInfo: ["ProfileInfo": profile])
            case .failure(let error):
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
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
    
    
    private func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension SplashViewController {
    private func setupSplashView() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code: code)
        }
    }
}

