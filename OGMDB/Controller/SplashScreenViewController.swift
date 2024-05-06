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

        fetchValues()
        checkNetworkConnection()
    }

    private let remoteConfig = RemoteConfig.remoteConfig()

    func fetchValues() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetch(withExpirationDuration: 0) { [weak self] status, error in
            guard let self = self else { return }
            if status == .success, error == nil {
                self.remoteConfig.activate(completion: { [weak self] _, error in
                    guard let self = self,
                          error == nil else {
                        return
                    }
                    let cachedValue = self.remoteConfig.configValue(forKey: "splashScreenLogoName").stringValue
                    print("fetched \(cachedValue ?? "no value")")

                    self.updateLogo(remoteConfigString: cachedValue ?? "ogmdbLogo")
                })
            } else {
                self.updateLogo(remoteConfigString: "ogmdbLogo")
            }
        }
    }

    func updateLogo(remoteConfigString: String) {
        DispatchQueue.main.async {
            self.splashScreenlogo.image = UIImage(named: remoteConfigString)
        }
    }

    func checkNetworkConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                monitor.cancel()
                self.goToHomeScreen()
                print("Internet connection is available.")
            } else {
                self.showNetworkError()
                print("Internet connection is not available.")
            }
        }
        monitor.start(queue: DispatchQueue.main)
    }

    private func showNetworkError() {
        let failAlert = UIAlertController(title: "Internete bağlı değilsiniz", message: "", preferredStyle: .alert)
        let failAction = UIAlertAction(title: "Tamam", style: .default)
        failAlert.addAction(failAction)
        present(failAlert, animated: true)
    }

    func goToHomeScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let vc = HomeScreenViewController(nibName: "HomeScreenViewController", bundle: nil)
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
}
