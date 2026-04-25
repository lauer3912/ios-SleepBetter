import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
    }

    private func setupAppearance() {
        tabBar.tintColor = UIColor.primaryColor
        tabBar.backgroundColor = UIColor.cardBackground

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.cardBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupViewControllers() {
        let dashboardVC = DashboardViewController()
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        dashboardNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "moon.fill"), tag: 0)

        let historyVC = SleepHistoryViewController()
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "chart.bar.fill"), tag: 1)

        let audioVC = AudioLibraryViewController()
        let audioNav = UINavigationController(rootViewController: audioVC)
        audioNav.tabBarItem = UITabBarItem(title: "Sounds", image: UIImage(systemName: "waveform"), tag: 2)

        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 3)

        viewControllers = [dashboardNav, historyNav, audioNav, settingsNav]
    }
}