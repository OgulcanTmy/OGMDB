//
//  UIViewController+Extension.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 3.06.2024.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String = "", buttonTitle: String = Constants.commonOk) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.tag = 999
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func hideLoading() {
        if let activityIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()

            view.isUserInteractionEnabled = true
        }
    }
}
