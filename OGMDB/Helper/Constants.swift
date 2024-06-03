//
//  Constants.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 3.06.2024.
//

import Foundation

enum Constants {
    static let commonOk = "Tamam"

    enum AppConstants {
        static let remoteConfigLogoKey = "splashScreenLogoName"
    }

    enum Image {
        static let ogmdbLogo = "ogmdbLogo"
    }

    enum Network {
        static let baseURL = "https://www.omdbapi.com/?apikey=483d6504"
    }

    enum HomeVC {
        static let minCharErrorTitle = "En az üç harf giriniz."
        static let unableToFetch = "Filmler yüklenirken bir sorunla karşılaşıldı."
    }

    enum SplashVC {
        static let noConnectionErrorTitle = "İnternete bağlı değilsiniz."
    }
}
