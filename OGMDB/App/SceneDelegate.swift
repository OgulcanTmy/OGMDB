//
//  SceneDelegate.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 8.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let viewController = SplashScreenViewController(
            nibName: String(describing: SplashScreenViewController.self),
            bundle: nil
        )
        let navigation = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigation

        self.window = window
        window.makeKeyAndVisible()
    }
}
