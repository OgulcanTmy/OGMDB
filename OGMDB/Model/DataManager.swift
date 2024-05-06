//
//  DataManager.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 29.01.2024.
//

//import Foundation
//import Alamofire
//
//struct DataManager {
//
//    
//    let baseUrl = "https://www.omdbapi.com/?i=tt3896198&apikey=483d6504"
//
//    
//
//
//    func performRequest(searchText: String) {
//        AF.request("\(baseUrl)"+"&t=\(searchText)", method: .get).response { response in
//            if let error = response.error {
//                print(error)
//            } else {
//                print(response)
//            }
//        }
//    }
//
//    func parseJSON(movieData: Data) {
//        let decoder = JSONDecoder()
//        do {
//            let decodedData = try decoder.decode(MovieData.self, from: movieData)
//            print (decodedData.title)
//        } catch {
//            print(error)
//        }
//
//        
//    }
//    }

