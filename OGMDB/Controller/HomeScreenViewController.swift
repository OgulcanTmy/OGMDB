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

    let baseUrl = "https://www.omdbapi.com/?apikey=483d6504"
    let cellName = String(describing: MovieCell.self)

    private var movies: [MovieModel] = [] {
        didSet {
            self.searchResultTableView.reloadData()
        }
    }

    private var currentPage = 1
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        searchResultTableView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellReuseIdentifier: cellName
        )
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let searchText = searchTextField.text, searchText.count > 2 else {
            debugPrint("Search bar empty")
            let failAlert = UIAlertController(title: "En az üç harf giriniz.", message: "", preferredStyle: .alert)
            let failAction = UIAlertAction(title: "Tamam", style: .default)
            failAlert.addAction(failAction)
            present(failAlert, animated: true)
            searchTextField.text = ""
            return
        }
        searchTextField.resignFirstResponder()
        movies.removeAll()

        currentPage = 1

        fetchData(for: searchText, page: currentPage)
    }

    private func fetchData(for searchText: String, page: Int) {
        guard !isLoading else { return }

        isLoading = true

        AF.request("\(baseUrl)&s=\(searchText)&page=\(page)", method: .get).response { [weak self] response in
            guard let self = self else { return }

            self.isLoading = false

            if let error = response.error {
                print(error)
            } else if let data = response.data,
                      let parsedData = self.parseJSON(from: data, into: SearchResponse.self) {
                self.movies.append(contentsOf: parsedData.search)
            }
        }
    }

    func parseJSON<T: Codable>(from data: Data, into modelType: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(modelType, from: data)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
}

extension HomeScreenViewController: UITextFieldDelegate {

}

extension HomeScreenViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellName,
            for: indexPath
        ) as? MovieCell else {
            return UITableViewCell()
        }
        cell.setupUI(with: movies[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchResultTableView.deselectRow(at: indexPath, animated: true)
        let movieID = movies[indexPath.row].movieID
        AF.request("\(baseUrl)&i=\(movieID)", method: .get).response { [weak self] response in
            guard let self = self else { return }
            if let error = response.error {
                print(error)
            } else if let data = response.data,
                      let movieData = self.parseJSON(from: data, into: MovieDetailModel.self) {
                let detailVC = MovieDetailViewController()
                detailVC.setModel(with: movieData)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            currentPage += 1
            fetchData(for: searchTextField.text ?? "", page: currentPage)
        }
    }
}

