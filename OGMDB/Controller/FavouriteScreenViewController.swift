//
//  FavouritesViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 29.08.2024.
//

import Alamofire
import CoreData
import UIKit

class FavouriteScreenViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let baseUrl = Constants.Network.baseURL
    private let cellName = String(describing: MovieCell.self)

    private var items: [MovieModel]? {
        didSet {
            updateBackgroundView()
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellReuseIdentifier: cellName
        )

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let context = CoreDataHelper.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        do {
            let items = try? context.fetch(fetchRequest)
            var itemsArray = [MovieModel]()
            items?.forEach { entity in
                itemsArray.append(
                    MovieModel(
                        title: entity.title,
                        movieId: entity.movieId,
                        poster: entity.poster,
                        year: entity.year
                    )
                )
            }
            self.items = itemsArray
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

    private func updateBackgroundView() {
        if let items = items, items.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = Constants.FavouriteVC.noMoviesAddedText
            messageLabel.textAlignment = .center
            messageLabel.textColor = .systemYellow
            messageLabel.font = .systemFont(ofSize: 18, weight: .medium)
            tableView.backgroundView = messageLabel
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension FavouriteScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellName,
            for: indexPath
        ) as? MovieCell,
            let items
        else {
            return UITableViewCell()
        }
        cell.setupUI(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        160
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        let movieID = items[indexPath.row].movieId ?? ""
        showLoading()
        AF.request("\(baseUrl)&i=\(movieID)", method: .get).response { [weak self] response in
            guard let self else { return }

            hideLoading()
            if response.error != nil {
                showAlert(title: Constants.HomeVC.unableToFetch)
            } else if let data = response.data,
                      var movieData = self.parseJSON(from: data, into: MovieDetailModel.self)
            {
                movieData.isFavourite = true
                movieData.movieId = movieID
                let detailVC = MovieDetailViewController(movieModel: movieData)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}
