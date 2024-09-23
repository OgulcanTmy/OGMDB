//
//  SplashScreenViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 11.01.2024.
//

import FirebaseRemoteConfig
import Network
import UIKit

final class SplashScreenViewController: UIViewController {
    @IBOutlet private var splashScreenlogo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        checkNetworkAndFetchLogo()
    }

    private let remoteConfig = RemoteConfig.remoteConfig()

    private func fetchLogoAndRoute() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetch(withExpirationDuration: 0) { [weak self] status, error in
            guard let self else { return }

            let logo = Constants.Image.ogmdbLogo
            if status == .success,
               error == nil
            {
                self.remoteConfig.activate(completion: { [weak self] _, error in
                    guard let self, error == nil else { return }

                    let rcLogoKey = Constants.AppConstants.remoteConfigLogoKey
                    let cachedValue = self.remoteConfig.configValue(forKey: rcLogoKey).stringValue
                    self.updateLogo(remoteConfigString: cachedValue)
                    goToHomeScreen()
                })
            } else {
                self.updateLogo(remoteConfigString: logo)
                goToHomeScreen()
            }
        }
    }

    private func updateLogo(remoteConfigString: String) {
        DispatchQueue.main.async {
            self.splashScreenlogo.image = UIImage(named: remoteConfigString)
        }
    }

    private func checkNetworkAndFetchLogo() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            if path.status == .satisfied {
                monitor.cancel()
                fetchLogoAndRoute()
            } else {
                let title = Constants.SplashVC.noConnectionErrorTitle
                showAlert(title: title)
            }
        }
        monitor.start(queue: DispatchQueue.main)
    }

    private func goToHomeScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let tabBarVC = UITabBarController()
            tabBarVC.tabBar.tintColor = .systemYellow
            tabBarVC.tabBar.unselectedItemTintColor = .systemYellow
            let homeVC = HomeScreenViewController(
                nibName: String(describing: HomeScreenViewController.self),
                bundle: nil
            )
            let homeItem = UITabBarItem(
                title: "Home",
                image: UIImage(systemName: "house"),
                tag: 0
            )
            homeVC.tabBarItem = homeItem

            let favVC = FavouriteScreenViewController(
                nibName: String(describing: FavouriteScreenViewController.self),
                bundle: nil
            )
            let favItem = UITabBarItem(
                title: "Favourites",
                image: UIImage(systemName: "heart"),
                selectedImage: UIImage(systemName: "heart.fill")
            )
            favVC.tabBarItem = favItem

            tabBarVC.viewControllers = [homeVC, favVC]
            self.navigationController?.setViewControllers([tabBarVC], animated: true)
        }
    }
}
