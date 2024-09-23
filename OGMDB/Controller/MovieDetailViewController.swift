//
//  MovieDetailViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 6.05.2024.
//

import CoreData
import Kingfisher
import UIKit

final class MovieDetailViewController: UIViewController {
    @IBOutlet private var moviePosterImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var rateLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!

    private var movieModel: MovieDetailModel
    private var notificationCell: NotificationCell?

    init(movieModel: MovieDetailModel) {
        self.movieModel = movieModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(with: movieModel)
        setupNotificationCell()
    }

    @IBAction private func favoriteButtonPressed(_ sender: Any) {
        movieModel.isFavourite?.toggle()

        favoriteButton.setImage(movieModel.isFavourite == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)

        let message = movieModel.isFavourite == true ? Constants.MovieDetailVC.favoriteMovieAddedText : Constants.MovieDetailVC.favoriteMovieRemovedText

        showNotification(message: message)

        let context = CoreDataHelper.shared.persistentContainer.viewContext
        let coord = context.persistentStoreCoordinator

        if movieModel.isFavourite == true {
            let entity = MovieEntity(context: context)
            entity.imdbRating = movieModel.imdbRating
            entity.movieId = movieModel.movieId
            entity.plot = movieModel.plot
            entity.poster = movieModel.poster
            entity.title = movieModel.title
            entity.year = movieModel.year
            try? context.save()
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
            let predicate = NSPredicate(format: "movieId == %@", movieModel.movieId ?? "")
            fetchRequest.predicate = predicate
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            _ = try? coord!.execute(deleteRequest, with: context)
        }
    }

    private func setupNotificationCell() {
        if let notificationCell = Bundle.main.loadNibNamed(
            "NotificationCell",
            owner: self,
            options: nil
        )?.first as? NotificationCell {
            self.notificationCell = notificationCell

            let padding: CGFloat = 20

            notificationCell.frame = CGRect(
                x: padding,
                y: -notificationCell.frame.height,
                width: view.frame.width - (2 * padding),
                height: 10
            )

            notificationCell.layer.cornerRadius = 10
            notificationCell.layer.masksToBounds = true

            view.addSubview(notificationCell)
        }
    }

    private func showNotification(message: String) {
        guard let notificationCell = notificationCell else { return }

        notificationCell.notificationLabel.text = message

        let safeAreaTopInset = view.safeAreaInsets.top
        let finalYPosition = safeAreaTopInset

        UIView.animate(withDuration: 0.5, animations: {
            notificationCell.frame.origin.y = finalYPosition
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5) {
                    notificationCell.frame.origin.y = -notificationCell.frame.height
                }
            }
        }
    }

    private func setupUI(with model: MovieDetailModel) {
        movieModel = model
        favoriteButton.setImage(
            movieModel.isFavourite == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"),
            for: .normal
        )
        titleLabel.text = movieModel.title ?? ""
        rateLabel.text = movieModel.imdbRating ?? ""
        descriptionLabel.text = movieModel.plot ?? ""
        moviePosterImageView.kf.indicatorType = .activity
        moviePosterImageView.kf.setImage(
            with: URL(string: model.poster ?? ""),
            placeholder: nil,
            options: [.cacheOriginalImage, .transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success: break
                case .failure:
                    moviePosterImageView.image = UIImage(named: Constants.Image.ogmdbLogo)
            }
        }
    }
}
