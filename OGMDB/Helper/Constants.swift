//
//  Constants.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 3.06.2024.
//

import Foundation

enum Constants {
    static let commonOk = "Ok"

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
        static let minCharErrorTitle = "Please type in at least 3 characters."
        static let unableToFetch = "An error occured while loading movies."
    }

    enum SplashVC {
        static let noConnectionErrorTitle = "You are not connected to the Internet."
    }

    enum FavouriteVC {
        static let noMoviesAddedText = "No favorite movies yet"
    }

    enum MovieDetailVC {
        static let favoriteMovieAddedText = "Added to Favorites !"
        static let favoriteMovieRemovedText = "Removed from Favorites !"
    }

}
