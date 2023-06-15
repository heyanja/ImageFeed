import UIKit
import Kingfisher
import SnapKit
import WebKit

final class ProfileViewController: UIViewController {
    
    private let token = OAuth2TokenStorage().token
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileInfoServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var avatarImage: UIImageView = {
        let element = UIImageView()
        element.image = Resources.Images.avatarImage
        element.layer.cornerRadius = 35
        element.layer.masksToBounds = true
        return element
    }()
    
    private lazy var nameLabel: UILabel = {
        let element = UILabel()
        element.text = "Екатерина Новикова"
        element.textColor = .ypWhite
        element.font = UIFont.boldSystemFont(ofSize: 23)
        return element
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let element = UILabel()
        element.text = "@ekaterina_nov"
        element.textColor = .ypGray
        element.font = UIFont.systemFont(ofSize: 13)
        return element
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let element = UILabel()
        element.text = "Hello, World!"
        element.textColor = .ypWhite
        element.font = UIFont.systemFont(ofSize: 13)
        return element
    }()
    
    private lazy var logoutButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(Resources.Images.logout, for: .normal)
        element.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
        
        profileImageObserver()
        profileInfoObserver()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        avatarImage.kf.setImage(with: url, placeholder: Resources.Images.avatarPlaceHolder)
    }
    
    private func profileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func profileInfoObserver() {
        profileInfoServiceObserver = NotificationCenter.default.addObserver(
            forName: SplashViewController.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateProfileDetails(profile: self.profileService.profile)
            }
        updateProfileDetails(profile: profileService.profile)
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName
        self.descriptionLabel.text = profile.bio
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record],
                                                        completionHandler: {})
            }
        }
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока-пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да",
                                      style: .default) { [weak self] _ in
            guard let self = self else { return }
            OAuth2TokenStorage().deleteToken()
            self.cleanCookies()
            let splashVC = SplashViewController()
            splashVC.isFirst = true
            splashVC.modalPresentationStyle = .fullScreen
            self.present(splashVC, animated: true)
        }
        let noAction = UIAlertAction(title: "Нет",
                                     style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
    @objc private func logout() {
        showLogoutAlert()
    }
}

extension ProfileViewController {
    private func addViews() {
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        addConstraints()
        
    }
    
    private func addConstraints() {
        avatarImage.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImage.snp.leading)
            make.top.equalTo(avatarImage.snp.bottom).inset(-8)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(16)
        }
        
        loginNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
            make.top.equalTo(nameLabel.snp.bottom).inset(-8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(loginNameLabel.snp.leading)
            make.trailing.equalTo(loginNameLabel.snp.trailing)
            make.top.equalTo(loginNameLabel.snp.bottom).inset(-8)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImage.snp.centerY)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(56)
            make.trailing.equalToSuperview().inset(26)
        }
    }
}



