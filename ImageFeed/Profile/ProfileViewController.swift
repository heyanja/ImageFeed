import UIKit
import Kingfisher
import SnapKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    let profileView = ProfileView()
    private let profileImageService = ProfileImageService.shared
    var presenter: ProfileViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addViews()
        
        presenter?.profileInfoObserver()
        presenter?.profileImageObserver()
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        profileView.avatarImage.kf.setImage(with: url, placeholder: Resources.Images.avatarPlaceHolder)
    }
    
    func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        self.profileView.nameLabel.text = profile.name
        self.profileView.loginNameLabel.text = profile.loginName
        self.profileView.descriptionLabel.text = profile.bio
    }
        
    @objc private func logout() {
        presenter?.showLogoutAlert(vc: self)
    }
}

extension ProfileViewController {
    private func addViews() {
        view.addSubview(profileView.avatarImage)
        view.addSubview(profileView.nameLabel)
        view.addSubview(profileView.loginNameLabel)
        view.addSubview(profileView.descriptionLabel)
        view.addSubview(profileView.logoutButton)
        profileView.logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        addConstraints()
    }
    
    private func addConstraints() {
        profileView.avatarImage.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(32)
        }
        
        profileView.nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.avatarImage.snp.leading)
            make.top.equalTo(profileView.avatarImage.snp.bottom).inset(-8)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(16)
        }
        
        profileView.loginNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.nameLabel.snp.leading)
            make.trailing.equalTo(profileView.nameLabel.snp.trailing)
            make.top.equalTo(profileView.nameLabel.snp.bottom).inset(-8)
        }
        
        profileView.descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.loginNameLabel.snp.leading)
            make.trailing.equalTo(profileView.loginNameLabel.snp.trailing)
            make.top.equalTo(profileView.loginNameLabel.snp.bottom).inset(-8)
        }
        
        profileView.logoutButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileView.avatarImage.snp.centerY)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(56)
            make.trailing.equalToSuperview().inset(26)
        }
    }
}



