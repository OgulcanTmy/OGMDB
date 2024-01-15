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

    override func viewWillAppear(_ animated: Bool) {
        fetchValues()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkNetworkConnection()
    }

    private let remoteConfig = RemoteConfig.remoteConfig()

    func fetchValues() {

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        self.remoteConfig.fetch(withExpirationDuration: 0, completionHandler: {status, error in
            if status == .success, error == nil {

                self.remoteConfig.activate(completion: { _, error in
                    guard error == nil else {
                        return
                    }
                    let cachedValue = self.remoteConfig.configValue(forKey: "splashScreenLogoName").stringValue
                    print("fetched \(cachedValue ?? "no value")")

                    self.updateLogo(remoteConfigString: cachedValue!)
                })

            }
            else {
                print("Something went wrong")
            }
        })
    }

    func updateLogo(remoteConfigString: String) {
        DispatchQueue.main.async {
            self.splashScreenlogo.image = UIImage(named: remoteConfigString)

        }
    }

    func checkNetworkConnection() {
        let monitor = NWPathMonitor()
        let failAlert = UIAlertController(title: "Internete bağlı değilsiniz", message: "", preferredStyle: .alert)
        let failAction = UIAlertAction(title: "Tamam", style: .default)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.goToHomeScreen()
                print("Internet connection is available.")
            } else {
                failAlert.addAction(failAction)
                self.present(failAlert, animated: true)
                print("Internet connection is not available.")
            }
        }

        monitor.start(queue: DispatchQueue.main)
    }
    func goToHomeScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let vc = HomeScreenViewController(nibName: "HomeScreenViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            vc.navigationItem.hidesBackButton = true
        }
    }
}
