//
//  MovieCell.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 7.05.2024.
//

import Kingfisher
import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet private var moviePoster: UIImageView!
    @IBOutlet private var movieName: UILabel!
    @IBOutlet private var movieYear: UILabel!

    func setupUI(with movie: MovieModel) {
        movieName.text = movie.title
        movieYear.text = movie.year
        moviePoster.kf.indicatorType = .activity
        moviePoster.contentMode = .scaleToFill
        moviePoster.kf.setImage(
            with: URL(string: movie.poster ?? ""),
            placeholder: nil,
            options: [.cacheOriginalImage, .transition(.fade(0.5))]
        ) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success: break
                case .failure:
                    moviePoster.image = UIImage(named: "ogmdbLogo")
            }
        }
        accessoryType = .disclosureIndicator
    }
}
