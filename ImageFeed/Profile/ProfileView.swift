import UIKit

final class ProfileView {
    lazy var avatarImage: UIImageView = {
        let element = UIImageView()
        element.image = Resourses.Images.avatarImage
        element.layer.cornerRadius = 35
        element.layer.masksToBounds = true
        return element
    }()
    
    lazy var nameLabel: UILabel = {
        let element = UILabel()
        element.textColor = .ypWhite
        element.font = UIFont.boldSystemFont(ofSize: 23)
        return element
    }()
    
    lazy var loginNameLabel: UILabel = {
        let element = UILabel()
        element.textColor = .ypGray
        element.font = UIFont.systemFont(ofSize: 13)
        return element
    }()
    
    lazy var descriptionLabel: UILabel = {
        let element = UILabel()
        element.textColor = .ypWhite
        element.font = UIFont.systemFont(ofSize: 13)
        return element
    }()
    
    lazy var logoutButton: UIButton = {
        let element = UIButton(type: .custom)
        element.setImage(Resourses.Images.logout, for: .normal)
        element.accessibilityIdentifier = "LogoutButton"
        return element
    }()
}
