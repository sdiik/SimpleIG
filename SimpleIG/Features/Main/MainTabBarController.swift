import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBar.backgroundColor = .white
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let reelVC = UINavigationController(rootViewController: CreatePostViewController())
        let profileVC = UINavigationController(rootViewController: ProfilePhotoViewController())

        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        reelVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "play.rectangle"), selectedImage: UIImage(systemName: "play.rectangle.fill"))
        profileVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle"), selectedImage: UIImage(systemName: "person.circle.fill"))

        viewControllers = [homeVC, reelVC, profileVC]
    }
}
