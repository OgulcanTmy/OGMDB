//
//  MovieDetailViewController.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 6.05.2024.
//

import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var movieModel: MovieDetailModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(with: movieModel!)
    }

    func setModel(with model: MovieDetailModel){
        movieModel = model
    }
    func setupUI(with model: MovieDetailModel) {
        movieModel = model
        titleLabel.text = movieModel?.title ?? ""
        rateLabel.text = movieModel?.imdbRating ?? ""
        descriptionLabel.text = movieModel?.plot ?? ""
        moviePosterImageView.kf.indicatorType = .activity
        moviePosterImageView.kf.setImage(
            with: URL(string: model.poster),
            placeholder: nil,
            options: [.cacheOriginalImage, .transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success: break
                case .failure:
                    moviePosterImageView.image = UIImage(named: "ogmdbLogo")
            }
        }
    }

}
