//
//  MovieNameCell.swift
//  OGMDB
//
//  Created by Oğulcan Tamyürek on 9.02.2024.
//

import UIKit

class MovieNameCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!

    func setupUI(with title: String) {
        movieTitleLabel.text = title
        accessoryType = .disclosureIndicator
    }

}
