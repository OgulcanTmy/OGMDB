//
//  MovieData.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 23.01.2024.
//

import Foundation

struct MovieName: Codable {
    let title: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
    }
}

struct SearchResponse: Codable {
    let search: [MovieName]

    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
}

struct MovieData: Codable {
    let title: String
    let year: String
    let runtime: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let imdbRating: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case imdbRating
    }
}
