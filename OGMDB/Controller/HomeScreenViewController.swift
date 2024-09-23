//
//  HomeScreenViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 12.01.2024.
//

import Alamofire
import CoreData
import UIKit

class HomeScreenViewController: UIViewController {
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var searchResultTableView: UITableView!

    private let baseUrl = Constants.Network.baseURL
    private let cellName = String(describing: MovieCell.self)

    private var movies: [MovieModel] = [] {
        didSet {
            searchResultTableView.reloadData()
        }
    }

    private var currentPage = 1
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultTableView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellReuseIdentifier: cellName
        )
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        hideKeyboardWhenTappedAround()
    }

    @IBAction private func searchButtonPressed(_ sender: Any) {
        guard let searchText = searchTextField.text, searchText.count > 2 else {
            let errorTitle = Constants.HomeVC.minCharErrorTitle
            showAlert(title: errorTitle)
            searchTextField.text = ""
            return
        }
        searchTextField.resignFirstResponder()
        movies.removeAll()

        currentPage = 1

        fetchData(for: searchText, page: currentPage, shouldShowLoading: true)
    }

    private func fetchData(for searchText: String, page: Int, shouldShowLoading: Bool = false) {
        guard !isLoading else { return }

        shouldShowLoading ? showLoading() : nil
        isLoading = true

        AF.request("\(baseUrl)&s=\(searchText)&page=\(page)", method: .get).response { [weak self] response in
            guard let self else { return }
            shouldShowLoading ? hideLoading() : nil
            self.isLoading = false

            if let _ = response.error {
                showAlert(title: Constants.HomeVC.unableToFetch)
            } else if let data = response.data,
                      let parsedData = self.parseJSON(from: data, into: SearchResponse.self),
                      let movies = parsedData.search
            {
                self.movies.append(contentsOf: movies)
            }
        }
    }

    private func parseJSON<T: Codable>(from data: Data, into modelType: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(modelType, from: data)
            return decodedData
        } catch {
            showAlert(title: Constants.HomeVC.unableToFetch)
            return nil
        }
    }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        160
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchResultTableView.deselectRow(at: indexPath, animated: true)
        let movieID = movies[indexPath.row].movieId ?? ""
        showLoading()
        AF.request("\(baseUrl)&i=\(movieID)", method: .get).response { [weak self] response in
            guard let self else { return }

            hideLoading()
            if response.error != nil {
                showAlert(title: Constants.HomeVC.unableToFetch)
            } else if let data = response.data,
                      var movieData = self.parseJSON(from: data, into: MovieDetailModel.self)
            {
                let context = CoreDataHelper.shared.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
                let predicate = NSPredicate(format: "movieId == %@", movieID)
                fetchRequest.predicate = predicate
                do {
                    let result = try? context.fetch(fetchRequest)
                    if result?.isEmpty == true || result == nil {
                        movieData.isFavourite = false
                    } else {
                        movieData.isFavourite = true
                    }
                }

                movieData.movieId = movieID
                let detailVC = MovieDetailViewController(movieModel: movieData)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            currentPage += 1
            fetchData(for: searchTextField.text ?? "", page: currentPage)
        }
    }
}
