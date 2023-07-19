import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: Resources.Images.tabBarItemProfile,
            selectedImage: nil)
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: Resources.Images.tabBarItemFeed,
            selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ypBlack
        self.tabBar.standardAppearance = appearance
        self.tabBar.tintColor = .ypWhite
    }
}
