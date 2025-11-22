import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let uid = DefaultManager.shared.get(DefaultManager.uid)
        let viewSelected = uid == nil ? LoginViewController() : MainTabBarController()
        let navController = UINavigationController(rootViewController: viewSelected)
        navController.navigationBar.prefersLargeTitles = true
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}
