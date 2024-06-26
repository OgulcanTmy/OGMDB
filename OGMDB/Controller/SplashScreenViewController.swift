//
//  SplashScreenViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 11.01.2024.
//

import UIKit
import Network
import FirebaseRemoteConfig

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var splashScreenlogo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        checkNetworkAndFetchLogo()
    }

    private let remoteConfig = RemoteConfig.remoteConfig()

    func fetchLogoAndRoute() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetch(withExpirationDuration: 0) { [weak self] status, error in
            guard let self = self else { return }
            let logo = Constants.Image.ogmdbLogo
            if status == .success,
                error == nil {
                self.remoteConfig.activate(completion: { [weak self] _, error in
                    guard let self = self, error == nil else { return }
                    let rcLogoKey = Constants.AppConstants.remoteConfigLogoKey
                    let cachedValue = self.remoteConfig.configValue(forKey: rcLogoKey).stringValue
                    self.updateLogo(remoteConfigString: cachedValue ?? logo)
                    goToHomeScreen()
                })
            } else {
                self.updateLogo(remoteConfigString: logo)
                goToHomeScreen()
            }
        }
    }

    func updateLogo(remoteConfigString: String) {
        DispatchQueue.main.async {
            self.splashScreenlogo.image = UIImage(named: remoteConfigString)
        }
    }

    func checkNetworkAndFetchLogo() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
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

    func goToHomeScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let vc = HomeScreenViewController(nibName: String(describing: HomeScreenViewController.self), bundle: nil)
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
}
