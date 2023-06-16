import UIKit

final class SplashView {
    lazy var logoImage: UIImageView = {
        let element = UIImageView()
        element.image = Resources.Images.launch
        return element
    }()
}
