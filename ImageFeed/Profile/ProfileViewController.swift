import UIKit
import Kingfisher
import SwiftKeychainWrapper
import SnapKit

final class ProfileViewController: UIViewController {
    
    private let token = OAuth2TokenStorage.Keys.bearerToken.rawValue
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileInfoServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var avatarImage: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "avatar_image")
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
        element.setImage(UIImage(named: "logout_icon"), for: .normal)
        element.addTarget(self, action: #selector(deleteKey), for: .touchUpInside)
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
        addConstraints()
        
        profileImageObserver()
        profileInfoObserver()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        avatarImage.kf.setImage(with: url, placeholder: UIImage(named: "avatarPlaceHolder"))
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
    
    private func addViews() {
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
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
    
    @objc private func deleteKey() {
        KeychainWrapper.standard.removeObject(forKey: token)
    }
}


