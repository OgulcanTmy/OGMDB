//
//  MovieCell.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 7.05.2024.
//

import UIKit
import Kingfisher

class MovieCell: UITableViewCell {

    @IBOutlet weak var moviePoster: UIImageView!
    
    @IBOutlet weak var movieName: UILabel!

    func setupUI(with movie: MovieModel) {
        movieName.text = movie.title
        moviePoster.kf.indicatorType = .activity
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
