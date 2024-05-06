//
//  HomeScreenViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 12.01.2024.
//

import UIKit
import Alamofire

class HomeScreenViewController: UIViewController {

    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchResultTableView: UITableView!

    let baseUrl = "https://www.omdbapi.com/?i=tt3896198&apikey=483d6504" // constanta tasinacak
    let cellName = String(describing: MovieNameCell.self)
    private var movieTitles: [String] = [] {
        didSet {
            self.searchResultTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        searchResultTableView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellReuseIdentifier: cellName
        )
        searchResultTableView.dataSource = self
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            debugPrint("Search bar empty")
            return
        }
        searchTextField.resignFirstResponder()
        movieTitles.removeAll()

        AF.request("\(baseUrl)&s=\(searchText)", method: .get).response { response in
            if let error = response.error {
                print(error) // error handling
            } else {
                self.parseJSON(movieName: response.data!)
            }
        }
    }

    func parseJSON(movieName: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedMovieData = try decoder.decode(SearchResponse.self, from: movieName)
            movieTitles = decodedMovieData.search.map { $0.title }
        } catch {
            print(error)
        }
    }

}

extension HomeScreenViewController: UITextFieldDelegate {

}

// MARK: - Tableview Datasource Methods

extension HomeScreenViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellName,
            for: indexPath
        ) as? MovieNameCell else {
            return UITableViewCell()
        }
        cell.setupUI(with: movieTitles[indexPath.row])
        return cell
    }
}
