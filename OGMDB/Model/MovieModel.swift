//
//  MovieData.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 23.01.2024.
//

import Foundation

struct MovieModel: Codable {
    let title: String?
    let movieID: String?
    let poster: String?
    let year: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case movieID = "imdbID"
        case poster = "Poster"
        case year = "Year"
    }
}

struct SearchResponse: Codable {
    let search: [MovieModel]?

    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
}

struct MovieDetailModel: Codable {
    let title: String?
    let year: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let imdbRating: String?
    let poster: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case poster = "Poster"
        case imdbRating
    }
}
