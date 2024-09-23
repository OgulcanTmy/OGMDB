//
//  MovieDetailViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 6.05.2024.
//

import UIKit
import Kingfisher
import CoreData

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    var movieModel: MovieDetailModel?
    var notificationCell: NotificationCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(with: movieModel!)
        setupNotificationCell()
    }

    @IBAction func favoriteButtonPressed(_ sender: Any) {

        movieModel?.isFavourite?.toggle()

        favoriteButton.setImage(movieModel?.isFavourite == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)

        let message = movieModel?.isFavourite == true ? Constants.MovieDetailVC.favoriteMovieAddedText : Constants.MovieDetailVC.favoriteMovieRemovedText

        showNotification(message: message)

        let context = CoreDataHelper.shared.persistentContainer.viewContext
        let coord = context.persistentStoreCoordinator

        if movieModel?.isFavourite == true {
            let entity = MovieEntity(context: context)
            entity.imdbRating = movieModel?.imdbRating
            entity.movieId = movieModel?.movieId
            entity.plot = movieModel?.plot
            entity.poster = movieModel?.poster
            entity.title = movieModel?.title
            entity.year = movieModel?.year
            do {
                try context.save()
                print("MovieEntity saved successfully!")
            } catch {
                print("Failed to save movie: \(error.localizedDescription)")
            }
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
            let predicate = NSPredicate(format: "movieId == %@", movieModel?.movieId ?? "")
            fetchRequest.predicate = predicate
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try coord!.execute(deleteRequest, with: context)
                print("MovieEntity deleted successfully!")
            } catch {
                print("Failed to delete movie: \(error.localizedDescription)")
            }
        }
    }

    func setupNotificationCell() {
        if let notificationCell = Bundle.main.loadNibNamed("NotificationCell", owner: self, options: nil)?.first as? NotificationCell {
            self.notificationCell = notificationCell

            let padding: CGFloat = 20

            _ = view.safeAreaInsets.top
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

    func showNotification(message: String) {
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

    func setModel(with model: MovieDetailModel){
        movieModel = model
    }

    func setupUI(with model: MovieDetailModel) {
        movieModel = model
        favoriteButton.setImage(movieModel?.isFavourite == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
        titleLabel.text = movieModel?.title ?? ""
        rateLabel.text = movieModel?.imdbRating ?? ""
        descriptionLabel.text = movieModel?.plot ?? ""
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
